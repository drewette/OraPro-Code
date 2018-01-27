<?php

set_time_limit(10000);

//how many rows to commit after
$commitblock = 10000;
//commit counter for loop
$commit_counter = 1;

//Get Environment parameters
if (isset($_REQUEST['ENV']))
{$ENV=$_REQUEST['ENV'];}
else
{$ENV='DEV';} //Default to Development Environment if not specified

//this is the number of records to load
if (isset($_REQUEST['LOAD']))
{$LOAD=$_REQUEST['LOAD'];}
else
{$LOAD='';}

//Set Entitlement
if ($ENV == 'DEV') {
require('connections-dev.php');
}

if ($ENV == 'TEST') {
require('connections-test.php');
}

if ($ENV == 'LIVE') {
require('connections-live.php');
}

//ID of customer for singleton transfer
if (isset($_REQUEST['ID']))
{$ID=$_REQUEST['ID'];}
else
{$ID='';}

$filesource = 'accounts_import.php';

//Oracle connection
$oracleConn = oci_connect($orc_username, $orc_password, $orc_server.':'.$orc_port.'/'.$orc_instance);

function validateArray($arrayVal){

$arrayVal = json_encode($arrayVal);
$arrayVal = str_replace('false','"false"',$arrayVal);
$arrayVal = str_replace('true','"true"',$arrayVal);
//check for Oracle reserved words and substitute
$arrayVal = str_replace('start','starting_from',$arrayVal);
$arrayVal = str_replace('_class','class',$arrayVal);
if ($arrayVal == '""') {$arrayVal = '';}

return $arrayVal;
}

//Mongodb connection to 'customer' database
$mdb_database = 'customer';
$mongodbConn = new MongoClient( "mongodb://".$mdb_username.":".$mdb_password."@".$mdb_server.":".$mdb_port."/".$mdb_database);

$table = "accounts";

//get current status of load
$sql = "BEGIN :r := pkg_platform_migration.get_status(p_table => :TABLE); END;";

// parse the statement
$sqlstring = oci_parse($oracleConn, $sql);
oci_bind_by_name($sqlstring,":TABLE",$table);
oci_bind_by_name($sqlstring, ':r', $status, 40);
oci_execute($sqlstring);

if ($status == 'running'){
exit; // exit script if already running
}
//flag running in mdb_error_log table

$status = "running";

$sql = "BEGIN
pkg_platform_migration.set_status(
p_table => :TABLE,
p_status => :STATUS);
END;";

// parse the statement
$sqlstring = oci_parse($oracleConn, $sql);
oci_bind_by_name($sqlstring,":TABLE",$table);
oci_bind_by_name($sqlstring,":STATUS",$status);
oci_execute($sqlstring);
//====================================================
//only truncate table on full migration
if ($ID==''){

$sql = oci_parse($oracleConn, 'truncate table mdb_accounts');
oci_execute($sql,OCI_COMMIT_ON_SUCCESS);

//wait until table is truncated
sleep("3");

}
//get collection accounts from mongoDB
$collection = $mongodbConn->customer->accounts;

//singleton migration or not?
if ($ID==''){
$cursor = $collection->find();
}
else{
$cursor = $collection->find(array('_id' => $ID));
}
//limit load size if required
if ($LOAD != 0){
$cursor -> limit($LOAD);
}

$cursor->fields(array( "_id" => true,
"_shardKey"=>true,
"firstPlayout"=>true,
"hasWallet"=>true,
"parentalPin"=>true,
"paymentPin"=>true,
"recentSearches"=>true,
"created"=>true,
"trackingIds"=>true,
"playouts"=>true,
"_class"=>true,
"paymentPinHash"=>true,
"isSuperUser"=>true));
try{

foreach ($cursor as $row => $value) {

$commit_counter++;

if(empty($value['_id']))
{$id = '';
}else{
$id = $value['_id'];
}

if(empty($value['created']))
{$created = '';
}else{
$created = date('d-M-Y h:i:s',$value['created']->sec);
}

if(empty($value['hasWallet']))
{$hasWallet = '';
}else{
$hasWallet = $value['hasWallet'];
}

if(empty($value['isSuperUser']))
{$isSuperUser = '';
}else{
$isSuperUser = $value['isSuperUser'];
}

$sql = "BEGIN
pkg_platform_migration.ACCOUNTS_LOAD(
P_ID => :ID,
P_SHARDKEY => '',
P_FIRSTPLAYOUT => '',
P_HASWALLET => :HASWALLET,
P_PARENTALPIN => '',
P_PAYMENTPIN => '',
P_RECENTSEARCHES => '',
P_CREATED => :CREATED,
P_TRACKINGIDS => '',
P_PLAYOUTS => '',
P_CLASS => '',
P_PAYMENTPINHASH => '',
P_ISSUPERUSER => :ISSUPERUSER);
END;";

// parse the statement
$sqlstring = oci_parse($oracleConn, $sql);

//these are CLOBs
/*
$firstPlayout_clob = oci_new_descriptor($oracleConn, OCI_D_LOB);
$parentalPin_clob = oci_new_descriptor($oracleConn, OCI_D_LOB);
$paymentPin_clob = oci_new_descriptor($oracleConn, OCI_D_LOB);
$recentSearches_clob = oci_new_descriptor($oracleConn, OCI_D_LOB);
$trackingIds_clob = oci_new_descriptor($oracleConn, OCI_D_LOB);
$class_clob = oci_new_descriptor($oracleConn, OCI_D_LOB);
*/

$id = strval($id);
$hasWallet = strval($hasWallet);
$created = strval($created);
$isSuperUser = strval($isSuperUser);

/*
$shardKey = strval($shardKey);
$firstPlayout = strval($firstPlayout);
$parentalPin = strval($parentalPin);
$paymentPin = strval($paymentPin);
$recentSearches = strval($recentSearches);
$trackingIds = strval($trackingIds);
$class = strval($class);
$paymentPinHash = strval($paymentPinHash);
*/

oci_bind_by_name($sqlstring,":ID",$id);
oci_bind_by_name($sqlstring,":HASWALLET",$hasWallet);
oci_bind_by_name($sqlstring,":CREATED",$created);
oci_bind_by_name($sqlstring,":ISSUPERUSER",$isSuperUser);

/*
oci_bind_by_name($sqlstring,":SHARDKEY",$shardKey);
oci_bind_by_name($sqlstring, ":FIRSTPLAYOUT", $firstPlayout_clob, -1, OCI_B_CLOB);
oci_bind_by_name($sqlstring, ":PARENTALPIN", $parentalPin_clob, -1, OCI_B_CLOB);
oci_bind_by_name($sqlstring, ":PAYMENTPIN", $paymentPin_clob, -1, OCI_B_CLOB);
oci_bind_by_name($sqlstring, ":RECENTSEARCHES", $recentSearches_clob, -1, OCI_B_CLOB);
oci_bind_by_name($sqlstring, ":TRACKINGIDS", $trackingIds_clob, -1, OCI_B_CLOB);
oci_bind_by_name($sqlstring, ":CLASS", $class_clob, -1, OCI_B_CLOB);
oci_bind_by_name($sqlstring,":PAYMENTPINHASH",$paymentPinHash);
*/

//assign data to clob variables
/*
$firstPlayout_clob->writetemporary($firstPlayout);
$parentalPin_clob->writetemporary($parentalPin);
$paymentPin_clob->writetemporary($paymentPin);
$recentSearches_clob->writetemporary($recentSearches);
$trackingIds_clob->writetemporary($trackingIds);
$class_clob->writetemporary($class);
*/

if ($commit_counter > $commitblock){
//commit and reset
oci_execute($sqlstring);
$commit_counter = 1;
}
else {
oci_execute($sqlstring, OCI_NO_AUTO_COMMIT);
}

}}

catch (MongoCursorException $e) {

$errorcode = $e->getCode();
$errormessage = $e->getMessage();
$error_datetime = date('d-M-Y h:i:s');

if ($errorcode != ''){
//insert into errorlog table
$errorsql = 'insert into mdb_error_log
(errorcode,
errormessage,
filesource,
error_datetime
)
values(
\''.$errorcode.'\',
\''.$errormessage.'\',
\''.$filesource.'\',
\''.$error_datetime.'\'
)';

$errorsql = oci_parse($oracleConn, $sqlstring);
oci_execute($errorsql,OCI_COMMIT_ON_SUCCESS);

}

}

oci_free_statement ($sqlstring);
//load complete, flag complete in mdb_error_log table

$table = "accounts";
$status = "complete";

$sql = "BEGIN
pkg_platform_migration.set_status(
p_table => :TABLE,
p_status => :STATUS);
END;";

// parse the statement
$sqlstring = oci_parse($oracleConn, $sql);
oci_bind_by_name($sqlstring,":TABLE",$table);
oci_bind_by_name($sqlstring,":STATUS",$status);
oci_execute($sqlstring);
//====================================================
//end of accounts import

//==================================================================
//close current mongodb connection
$mongodbConn->close();
//close Oracle connnection
oci_close($oracleConn);
//==================================================================

?>