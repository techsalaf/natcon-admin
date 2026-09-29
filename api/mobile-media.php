<?php
declare(strict_types=1);
require_once dirname(__DIR__).'/services/natcon/bootstrap.php';
use function Natcon\{config,database,query,staffForToken};

try {
    $eventId=filter_var($_GET['event_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);
    $kind=(string)($_GET['kind']??'');
    if(!$eventId||!in_array($kind,['image','cover'],true)){http_response_code(404);exit;}
    $db=database(config());
    $row=query($db,"SELECT e.status,p.image_base64,p.cover_base64 FROM natcon_events e LEFT JOIN natcon_event_profiles p ON p.event_id=e.id WHERE e.id=?",[$eventId])->fetch();
    if(!$row){http_response_code(404);exit;}
    if($row['status']!=='published'&&!staffForToken($db)){http_response_code(404);exit;}
    $encoded=$kind==='cover'?$row['cover_base64']:$row['image_base64'];$bytes=is_string($encoded)?base64_decode($encoded,true):false;
    if(!$bytes){http_response_code(404);exit;}
    $mime=match(true){str_starts_with($bytes,"\xFF\xD8\xFF")=>'image/jpeg',str_starts_with($bytes,"\x89PNG\r\n\x1A\n")=>'image/png',substr($bytes,0,4)==='GIF8'=>'image/gif',substr($bytes,0,4)==='RIFF'&&substr($bytes,8,4)==='WEBP'=>'image/webp',default=>null};
    if(!$mime){http_response_code(404);exit;}
    $cacheControl=$row['status']==='published'?'public, max-age=300':'private, no-store';header('Content-Type: '.$mime);header('Content-Length: '.strlen($bytes));header('Cache-Control: '.$cacheControl);header('X-Content-Type-Options: nosniff');echo $bytes;
} catch(Throwable $e) {
    error_log('NATCON mobile media: '.$e->getMessage());http_response_code(503);
}
