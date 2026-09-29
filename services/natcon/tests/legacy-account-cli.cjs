'use strict';
const assert=require('node:assert/strict');
const {spawnSync}=require('node:child_process');
const fs=require('node:fs');
const os=require('node:os');
const path=require('node:path');
const repo=path.resolve(__dirname,'../../..');
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'natcon-legacy-cli-'));
const database=path.join(temp,'natcon.sqlite').replaceAll('\\','/');
const env={...process.env,NATCON_DSN:`sqlite:${database}`,NATCON_DB_USER:'',NATCON_DB_PASSWORD:'',NATCON_BASE_URL:'http://localhost'};
const phpQuote=value=>`'${value.replaceAll('\\','\\\\').replaceAll("'","\\'")}'`;
const bootstrap=path.join(repo,'services/natcon/bootstrap.php');
const seed=`require ${phpQuote(bootstrap)}; $db=new PDO(${phpQuote(`sqlite:${database}`)}); Natcon\\migrate($db); $db->exec('CREATE TABLE tbl_user(id INTEGER PRIMARY KEY,name TEXT,email TEXT,ccode TEXT,mobile TEXT,password TEXT,refercode INTEGER,parentcode INTEGER,reg_date TEXT,status INTEGER,pro_pic TEXT,wallet INTEGER)'); $db->exec("INSERT INTO tbl_user VALUES(1,'CLI Legacy','cli@example.test','+234','08000009999','cli-legacy-password',876543,NULL,'2025-01-01 00:00:00',1,'',1250)");`;
function php(args){const result=spawnSync('php',args,{cwd:repo,env,encoding:'utf8'});assert.equal(result.status,0,result.stderr||result.stdout);return result.stdout.trim();}
try{
  php(['-r',seed]);
  const dry=JSON.parse(php(['services/natcon/cli.php','legacy-accounts']));
  assert.equal(dry.dry_run,true);assert.equal(dry.would_import,1);assert.equal(dry.wallet_liability_kobo,125000);
  const applied=JSON.parse(php(['services/natcon/cli.php','legacy-accounts','--apply']));
  assert.equal(applied.imported,1);assert.equal(applied.dry_run,false);assert.match(applied.batch_id,/^legacy-accounts-/);
  const rolled=JSON.parse(php(['services/natcon/cli.php','legacy-accounts','--rollback',applied.batch_id]));
  assert.equal(rolled.rolled_back,1);
  const final=php(['-r',`require ${phpQuote(bootstrap)}; $db=new PDO(${phpQuote(`sqlite:${database}`)}); echo $db->query('SELECT COUNT(*) FROM natcon_accounts WHERE email="cli@example.test"')->fetchColumn().':'.$db->query('SELECT COUNT(*) FROM tbl_user')->fetchColumn();`]);
  assert.equal(final,'0:1');
  console.log('PASS legacy-account CLI dry-run, apply, and rollback on isolated SQLite');
}finally{fs.rmSync(temp,{recursive:true,force:true});}
