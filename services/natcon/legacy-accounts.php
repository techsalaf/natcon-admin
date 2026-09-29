<?php
declare(strict_types=1);
namespace Natcon;

function legacyAccountFingerprint(array $account): string {
    $fields=['id','name','email','country_code','phone','password_hash','profile_image','referral_code','referred_by','wallet_balance_kobo','status'];
    $stable=[];foreach($fields as $field)$stable[$field]=(string)($account[$field]??'');return hash('sha256',json_encode($stable,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR));
}

function legacyAccountTableExists(\PDO $db): bool {
    if($db->getAttribute(\PDO::ATTR_DRIVER_NAME)==='sqlite')return (bool)query($db,"SELECT 1 FROM sqlite_master WHERE type='table' AND name='tbl_user'")->fetchColumn();
    return (bool)query($db,"SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tbl_user'")->fetchColumn();
}

function legacyAccountRows(\PDO $db): array {
    if(!legacyAccountTableExists($db))throw new \RuntimeException('Legacy table tbl_user was not found; no accounts were changed.');
    $rows=query($db,'SELECT id,name,email,ccode,mobile,password,refercode,parentcode,reg_date,status,pro_pic,wallet FROM tbl_user ORDER BY id')->fetchAll();
    return $rows;
}

function inspectLegacyAccounts(\PDO $db): array {
    $rows=legacyAccountRows($db);$counts=['source_total'=>count($rows),'would_import'=>0,'already_imported'=>0,'conflict_or_invalid'=>0,'wallet_liability_kobo'=>0];
    foreach($rows as $row){if(query($db,'SELECT id FROM natcon_legacy_account_imports WHERE source_table=? AND source_id=?',['tbl_user',(string)$row['id']])->fetchColumn()){$counts['already_imported']++;continue;}
        $name=trim((string)$row['name']);$email=strtolower(trim((string)$row['email']));$country=trim((string)$row['ccode']);$phone=trim((string)$row['mobile']);$password=(string)$row['password'];$wallet=filter_var($row['wallet'],FILTER_VALIDATE_INT);
        $valid=$name!==''&&filter_var($email,FILTER_VALIDATE_EMAIL)&&preg_match('/^[+0-9 -]{6,40}$/',$phone)&&$password!==''&&strlen($password)<=4096&&$wallet!==false&&$wallet>=0&&$wallet<=2147483647;
        if(!$valid||query($db,'SELECT id FROM natcon_accounts WHERE email=? OR (country_code=? AND phone=?) LIMIT 1',[$email,$country,$phone])->fetchColumn()){$counts['conflict_or_invalid']++;continue;}
        $counts['would_import']++;$counts['wallet_liability_kobo']+=(int)$wallet*100;
    }
    return $counts;
}

function importLegacyAccounts(\PDO $db,string $batchId,bool $apply=false): array {
    if(!preg_match('/^legacy-accounts-[A-Za-z0-9_-]{8,64}$/',$batchId))throw new \InvalidArgumentException('Use a unique legacy-accounts batch identifier.');
    $preview=inspectLegacyAccounts($db);$result=$preview+['batch_id'=>$batchId,'imported'=>0,'skipped'=>0,'dry_run'=>!$apply];
    if(!$apply)return $result;
    $db->beginTransaction();try{$rows=legacyAccountRows($db);$legacyCodeToTarget=[];$created=[];
        foreach($rows as $row){$sourceId=(string)$row['id'];if(query($db,'SELECT id FROM natcon_legacy_account_imports WHERE source_table=? AND source_id=?',['tbl_user',$sourceId])->fetchColumn()){$result['skipped']++;continue;}
            $name=trim((string)$row['name']);$email=strtolower(trim((string)$row['email']));$country=trim((string)$row['ccode']);$phone=trim((string)$row['mobile']);$password=(string)$row['password'];$wallet=filter_var($row['wallet'],FILTER_VALIDATE_INT);
            $valid=$name!==''&&filter_var($email,FILTER_VALIDATE_EMAIL)&&preg_match('/^[+0-9 -]{6,40}$/',$phone)&&$password!==''&&strlen($password)<=4096&&$wallet!==false&&$wallet>=0&&$wallet<=2147483647;
            if(!$valid||query($db,'SELECT id FROM natcon_accounts WHERE email=? OR (country_code=? AND phone=?) LIMIT 1',[$email,$country,$phone])->fetchColumn()){$result['skipped']++;continue;}
            $legacyCode=trim((string)$row['refercode']);$code=$legacyCode!==''&&preg_match('/^[A-Za-z0-9_-]{3,32}$/',$legacyCode)&&!query($db,'SELECT id FROM natcon_accounts WHERE referral_code=?',[$legacyCode])->fetchColumn()?$legacyCode:strtoupper(bin2hex(random_bytes(6)));
            $status=(string)$row['status']==='1'?'active':'disabled';$registered=trim((string)$row['reg_date']);if(!preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/',$registered))$registered=now();
            query($db,'INSERT INTO natcon_accounts(name,email,country_code,phone,password_hash,profile_image,referral_code,wallet_balance_kobo,status,created_at,updated_at) VALUES(?,?,?,?,?,?,?,?,?,?,?)',[$name,$email,$country,$phone,password_hash($password,PASSWORD_DEFAULT),trim((string)$row['pro_pic'])?:null,$code,(int)$wallet*100,$status,$registered,now()]);$target=(int)$db->lastInsertId();
            if((int)$wallet>0)query($db,'INSERT INTO natcon_wallet_ledger(account_id,direction,amount_kobo,reference,status,description,created_at) VALUES(?,?,?,?,?,?,?)',[$target,'credit',(int)$wallet*100,'LEGACY-WALLET-'.$sourceId,'completed','Imported legacy wallet balance',now()]);
            query($db,'INSERT INTO natcon_legacy_account_imports(batch_id,source_table,source_id,target_id,target_fingerprint,wallet_kobo,created_at) VALUES(?,?,?,?,?,?,?)',[$batchId,'tbl_user',$sourceId,$target,'',(int)$wallet*100,now()]);$legacyCodeToTarget[$legacyCode]=$target;$created[$sourceId]=['target_id'=>$target,'parentcode'=>trim((string)$row['parentcode']),'legacy_code'=>$legacyCode];$result['imported']++;
        }
        foreach($created as $sourceId=>$item){$parentCode=$item['parentcode'];if($parentCode==='')continue;$referrer=$legacyCodeToTarget[$parentCode]??query($db,"SELECT id FROM natcon_accounts WHERE referral_code=? AND status='active'",[$parentCode])->fetchColumn();if(!$referrer||(int)$referrer===$item['target_id'])continue;
            query($db,'UPDATE natcon_accounts SET referred_by=? WHERE id=?',[(int)$referrer,$item['target_id']]);$ignore=$db->getAttribute(\PDO::ATTR_DRIVER_NAME)==='sqlite'?'INSERT OR IGNORE':'INSERT IGNORE';query($db,"$ignore INTO natcon_referrals(referrer_account_id,referred_account_id,referral_code,reward_kobo,status,created_at) VALUES(?,?,?,?,?,?)",[(int)$referrer,$item['target_id'],$parentCode,0,'pending',now()]);
        }
        foreach($created as $item){$account=query($db,'SELECT id,name,email,country_code,phone,password_hash,profile_image,referral_code,referred_by,wallet_balance_kobo,status FROM natcon_accounts WHERE id=?',[$item['target_id']])->fetch();query($db,'UPDATE natcon_legacy_account_imports SET target_fingerprint=? WHERE batch_id=? AND target_id=?',[legacyAccountFingerprint($account),$batchId,$item['target_id']]);}
        audit($db,'cli','legacy_accounts_imported',$batchId,['imported'=>$result['imported'],'skipped'=>$result['skipped'],'wallet_liability_kobo'=>$result['wallet_liability_kobo']]);$db->commit();$result['dry_run']=false;return $result;
    }catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}

function rollbackLegacyAccountImport(\PDO $db,string $batchId): array {
    if(!preg_match('/^legacy-accounts-[A-Za-z0-9_-]{8,64}$/',$batchId))throw new \InvalidArgumentException('Choose a valid legacy-account import batch.');
    $db->beginTransaction();try{$rows=query($db,'SELECT m.id AS map_id,m.batch_id,m.source_table,m.source_id,m.target_id,m.target_fingerprint,m.wallet_kobo,a.id AS account_id,a.name,a.email,a.country_code,a.phone,a.password_hash,a.profile_image,a.referral_code,a.referred_by,a.wallet_balance_kobo,a.status FROM natcon_legacy_account_imports m JOIN natcon_accounts a ON a.id=m.target_id WHERE m.batch_id=? ORDER BY m.target_id DESC',[$batchId])->fetchAll();if(!$rows)throw new \InvalidArgumentException('No imported accounts were found for that batch.');
        foreach($rows as $row){$id=(int)$row['target_id'];$account=['id'=>$row['account_id'],'name'=>$row['name'],'email'=>$row['email'],'country_code'=>$row['country_code'],'phone'=>$row['phone'],'password_hash'=>$row['password_hash'],'profile_image'=>$row['profile_image'],'referral_code'=>$row['referral_code'],'referred_by'=>$row['referred_by'],'wallet_balance_kobo'=>$row['wallet_balance_kobo'],'status'=>$row['status']];if(!hash_equals((string)$row['target_fingerprint'],legacyAccountFingerprint($account)))throw new \RuntimeException('Rollback refused: an imported account has changed since migration.');
            foreach(['natcon_mobile_tokens'=>'principal_id','natcon_orders'=>'account_id','natcon_favorites'=>'account_id','natcon_reviews'=>'account_id','natcon_notifications'=>'account_id','natcon_devices'=>'account_id','natcon_chat_threads'=>'account_id'] as $table=>$column)if(query($db,"SELECT 1 FROM $table WHERE $column=? LIMIT 1",[$id])->fetchColumn())throw new \RuntimeException('Rollback refused: at least one imported account has been used in NATCON.');
            if(query($db,"SELECT 1 FROM natcon_referrals WHERE referred_account_id=? AND (status<>'pending' OR reward_kobo<>0) LIMIT 1",[$id])->fetchColumn())throw new \RuntimeException('Rollback refused: an imported referral has been converted or rewarded.');
            if(query($db,'SELECT 1 FROM natcon_referrals WHERE referrer_account_id=? AND referred_account_id NOT IN (SELECT target_id FROM natcon_legacy_account_imports WHERE batch_id=?) LIMIT 1',[$id,$batchId])->fetchColumn())throw new \RuntimeException('Rollback refused: a new NATCON account refers to an imported account.');
            if((int)$row['wallet_kobo']>0){$wallet=query($db,'SELECT id,amount_kobo FROM natcon_wallet_ledger WHERE account_id=? AND reference=? AND direction=?',[$id,'LEGACY-WALLET-'.$row['source_id'],'credit'])->fetch();if(!$wallet||(int)$wallet['amount_kobo']!==(int)$row['wallet_kobo'])throw new \RuntimeException('Rollback refused: the imported wallet entry changed.');query($db,'DELETE FROM natcon_wallet_ledger WHERE id=?',[$wallet['id']]);}
        }
        query($db,'DELETE FROM natcon_referrals WHERE referred_account_id IN (SELECT target_id FROM natcon_legacy_account_imports WHERE batch_id=?) AND status=\'pending\' AND reward_kobo=0',[$batchId]);$ids=array_column($rows,'target_id');foreach($ids as $id){query($db,'DELETE FROM natcon_legacy_account_imports WHERE batch_id=? AND target_id=?',[$batchId,$id]);query($db,'DELETE FROM natcon_accounts WHERE id=?',[$id]);}
        audit($db,'cli','legacy_accounts_rolled_back',$batchId,['removed_count'=>count($rows)]);$db->commit();return ['batch_id'=>$batchId,'rolled_back'=>count($rows)];
    }catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
