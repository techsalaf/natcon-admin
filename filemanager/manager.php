<?php
require "evconfing.php";
require "event.php";
function siteURL() {
  $protocol = ((!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') || 
    $_SERVER['SERVER_PORT'] == 443) ? "https://" : "http://";
  $domainName = $_SERVER['HTTP_HOST'];
  return $protocol.$domainName;
}

if (isset($_POST["type"])) {
    if ($_POST["type"] == "login") {
        $username = $_POST["username"];
        $password = $_POST["password"];
        $stype = $_POST["stype"];
        if ($stype == "mowner") {
            $h = new Event();

            $count = $h->evmultilogin($username, $password, "admin");
            if ($count != 0) {
                $_SESSION["evename"] = $username;
                $_SESSION["stype"] = $stype;
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Login Successfully!",
                    "message" => "welcome admin!!",
                    "action" => "dashboard.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" => "Please Use Valid Data!!",
                    "message" => "Invalid Data!!",
                    "action" => "index.php",
                ];
            }
        } else {
            $h = new Event();

            $count = $h->evmultilogin($username, $password, "tbl_sponsore");
            if ($count != 0) {
                $_SESSION["evename"] = $username;
                $_SESSION["stype"] = $stype;
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Login Successfully!",
                    "message" => "welcome Sponsore!!",
                    "action" => "dashboard.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" => "Please Use Valid Data!!",
                    "message" => "Invalid Data!!",
                    "action" => "index.php",
                ];
            }
        }
    }
	elseif ($_POST["type"] == "add_category") {
        $okey = $_POST["status"];
        $title = $evmulti->real_escape_string($_POST["title"]);
		
		
        $target_dir = dirname(dirname(__FILE__)) . "/images/category/";
        $url = "images/category/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
		
		$target_dirs = dirname(dirname(__FILE__)) . "/images/category/";
        $urls = "images/category/";
        $temps = explode(".", $_FILES["cover_img"]["name"]);
        $newfilenames = uniqid().round(microtime(true)) . "." . end($temps);
        $target_files = $target_dirs. basename($newfilenames);
        $urls = $urls . basename($newfilenames);
		
       
            move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
			move_uploaded_file($_FILES["cover_img"]["tmp_name"], $target_files);
            $table = "tbl_category";
            $field_values = ["img", "status", "title","cover"];
            $data_values = ["$url", "$okey", "$title","$urls"];

            $h = new Event();
            $check = $h->evmultiinsertdata($field_values, $data_values, $table);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Category Add Successfully!!",
                    "message" => "Category section!",
                    "action" => "list_category.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_category.php",
                ];
            }
        
    }elseif ($_POST["type"] == "edit_category") {
        $okey = $_POST["status"];
        $id = $_POST["id"];
        $title = $evmulti->real_escape_string($_POST["title"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/category/";
        $url = "images/category/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
		
		$target_dirs = dirname(dirname(__FILE__)) . "/images/category/";
        $urls = "images/category/";
        $temps = explode(".", $_FILES["cover_img"]["name"]);
        $newfilenames = uniqid().round(microtime(true)) . "." . end($temps);
        $target_files = $target_dirs . basename($newfilenames);
        $urls = $urls . basename($newfilenames);
		
        if ($_FILES["cat_img"]["name"] != "" and $_FILES["cover_img"]["name"] == "") {
           
                move_uploaded_file(
                    $_FILES["cat_img"]["tmp_name"],
                    $target_file
                );
                $table = "tbl_category";
                $field = ["status" => $okey, "img" => $url, "title" => $title];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Category Update Successfully!!",
                        "message" => "Category section!",
                        "action" => "list_category.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "add_category.php?id=" . $id . "",
                    ];
                }
            
        } else if ($_FILES["cat_img"]["name"] == "" and $_FILES["cover_img"]["name"] != "") {
           
                move_uploaded_file(
                    $_FILES["cover_img"]["tmp_name"],
                    $target_files
                );
                $table = "tbl_category";
                $field = ["status" => $okey, "cover" => $urls, "title" => $title];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Category Update Successfully!!",
                        "message" => "Category section!",
                        "action" => "list_category.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "add_category.php?id=" . $id . "",
                    ];
                }
            
        }else if ($_FILES["cat_img"]["name"] != "" and $_FILES["cover_img"]["name"] != "") {
            
           
                move_uploaded_file(
                    $_FILES["cat_img"]["tmp_name"],
                    $target_file
                );
				
				 move_uploaded_file(
                    $_FILES["cover_img"]["tmp_name"],
                    $target_files
                );
                $table = "tbl_category";
                $field = ["status" => $okey, "cover" => $urls,"img" => $url, "title" => $title];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Category Update Successfully!!",
                        "message" => "Category section!",
                        "action" => "list_category.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "add_category.php?id=" . $id . "",
                    ];
                }
            
        }else {
            $table = "tbl_category";
            $field = ["status" => $okey, "title" => $title];
            $where = "where id=" . $id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Category Update Successfully!!",
                    "message" => "Category section!",
                    "action" => "list_category.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_category.php?id=" . $id . "",
                ];
            }
        }
    }elseif ($_POST["type"] == "add_page") {
        $ctitle = $evmulti->real_escape_string($_POST["ctitle"]);
        $cstatus = $_POST["cstatus"];
        $cdesc = $evmulti->real_escape_string($_POST["cdesc"]);
        $table = "tbl_page";

        $field_values = ["description", "status", "title"];
        $data_values = ["$cdesc", "$cstatus", "$ctitle"];

        $h = new Event();
        $check = $h->evmultiinsertdata($field_values, $data_values, $table);
        if ($check == 1) {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "title" => "page Add Successfully!!",
                "message" => "page section!",
                "action" => "list_page.php",
            ];
        } else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "title" =>
                    "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                "message" => "Operation DISABLED!!",
                "action" => "add_page.php",
            ];
        }
    } elseif ($_POST["type"] == "edit_page") {
        $id = $_POST["id"];
        $ctitle = $evmulti->real_escape_string($_POST["ctitle"]);
        $cstatus = $_POST["cstatus"];
        $cdesc = $evmulti->real_escape_string($_POST["cdesc"]);

        $table = "tbl_page";
        $field = [
            "description" => $cdesc,
            "status" => $cstatus,
            "title" => $ctitle,
        ];
        $where = "where id=" . $id . "";
        $h = new Event();
        $check = $h->evmultiupdateData($field, $table, $where);
        if ($check == 1) {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "title" => "page Update Successfully!!",
                "message" => "page section!",
                "action" => "list_page.php",
            ];
        } else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "title" =>
                    "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                "message" => "Operation DISABLED!!",
                "action" => "add_page.php?id=" . $id . "",
            ];
        }
    }
	elseif ($_POST["type"] == "add_faq") {
        $okey = $_POST["status"];
        $question = $evmulti->real_escape_string($_POST["question"]);
        $answer = $evmulti->real_escape_string($_POST["answer"]);
        
        $table = "tbl_faq";
        $field_values = ["question", "answer", "status"];
        $data_values = ["$question", "$answer", "$okey"];

        $h = new Event();
        $check = $h->evmultiinsertdata($field_values, $data_values, $table);
        if ($check == 1) {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "title" => "FAQ Add Successfully!!",
                "message" => "FAQ section!",
                "action" => "list_faq.php",
            ];
        } else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "title" =>
                    "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                "message" => "Operation DISABLED!!",
                "action" => "add_faq.php",
            ];
        }
    }
	elseif ($_POST["type"] == "edit_faq") {
        $okey = $_POST["status"];
        $question = $evmulti->real_escape_string($_POST["question"]);
        $answer = $evmulti->real_escape_string($_POST["answer"]);
        $id = $_POST["id"];
        $table = "tbl_faq";
        $field = [
            "status" => $okey,
            "answer" => $answer,
            "question" => $question,
        ];
        $where = "where id=" . $id . "";
        $h = new Event();
        $check = $h->evmultiupdateData($field, $table, $where);
        if ($check == 1) {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "title" => "FAQ Update Successfully!!",
                "message" => "FAQ Code section!",
                "action" => "list_faq.php",
            ];
        } else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "title" =>
                    "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                "message" => "Operation DISABLED!!",
                "action" => "add_faq.php?id=" . $id . "",
            ];
        }
    }
elseif ($_POST["type"] == "edit_payment") {
        $dname = mysqli_real_escape_string($evmulti, $_POST["cname"]);
        $attributes = mysqli_real_escape_string($evmulti, $_POST["p_attr"]);
        $ptitle = mysqli_real_escape_string($evmulti, $_POST["ptitle"]);
        $okey = $_POST["status"];
        $id = $_POST["id"];
        $p_show = $_POST["p_show"];
        $target_dir = dirname(dirname(__FILE__)) . "/images/payment/";
        $url = "images/payment/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        if ($_FILES["cat_img"]["name"] != "") {
            
                move_uploaded_file(
                    $_FILES["cat_img"]["tmp_name"],
                    $target_file
                );
                $table = "tbl_payment_list";
                $field = [
                    "title" => $dname,
                    "status" => $okey,
                    "img" => $url,
                    "attributes" => $attributes,
                    "subtitle" => $ptitle,
                    "p_show" => $p_show,
                ];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Payment Gateway Update Successfully!!",
                        "message" => "Payment Gateway section!",
                        "action" => "payment_list.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "edit_payment.php?id=" . $id . "",
                    ];
                }
            
        } else {
            $table = "tbl_payment_list";
            $field = [
                "title" => $dname,
                "status" => $okey,
                "attributes" => $attributes,
                "subtitle" => $ptitle,
                "p_show" => $p_show,
            ];
            $where = "where id=" . $id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Payment Gateway Update Successfully!!",
                    "message" => "Payment Gateway section!",
                    "action" => "payment_list.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "edit_payment.php?id=" . $id . "",
                ];
            }
        }
    }
elseif ($_POST["type"] == "edit_profile") {
        $dname = $_POST["email"];
        $dsname = $_POST["password"];
        $id = $_POST["id"];
        $table = "admin";
        $field = ["username" => $dname, "password" => $dsname];
        $where = "where id=" . $id . "";
        $h = new Event();
        $check = $h->evmultiupdateData($field, $table, $where);
        if ($check == 1) {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "title" => "Profile Update Successfully!!",
                "message" => "Profile  section!",
                "action" => "profile.php",
            ];
        } else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "title" =>
                    "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                "message" => "Operation DISABLED!!",
                "action" => "profile.php",
            ];
        }
    } elseif ($_POST["type"] == "edit_setting") {
        $webname = mysqli_real_escape_string($evmulti, $_POST["webname"]);
        $timezone = $_POST["timezone"];
        $currency = $_POST["currency"];
        $pstore = $_POST["pstore"];
$tax = $_POST['tax'];
        $id = $_POST["id"];

        $one_key = $_POST["one_key"];

        $one_hash = $_POST["one_hash"];
        $s_key = $_POST["s_key"];

        $s_hash = $_POST["s_hash"];

        
        
        $scredit = $_POST["scredit"];
        $rcredit = $_POST["rcredit"];

        $target_dir = dirname(dirname(__FILE__)) . "/images/website/";
        $url = "images/website/";
        $temp = explode(".", $_FILES["weblogo"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        if ($_FILES["weblogo"]["name"] != "") {
            
                move_uploaded_file(
                    $_FILES["weblogo"]["tmp_name"],
                    $target_file
                );
                $table = "tbl_setting";
                $field = [
                   
                    "timezone" => $timezone,
                    "weblogo" => $url,
                    "webname" => $webname,
                    "currency" => $currency,
                    "pstore" => $pstore,
                    "one_key" => $one_key,
                    "one_hash" => $one_hash,
                    "s_key" => $s_key,
                    "s_hash" => $s_hash,
                    "scredit" => $scredit,
                    "rcredit" => $rcredit,
					"tax"=>$tax
                ];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Setting Update Successfully!!",
                        "message" => "Setting section!",
                        "action" => "setting.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "setting.php",
                    ];
                }
            
        } else {
            $table = "tbl_setting";
            $field = [
                
                "timezone" => $timezone,
                "webname" => $webname,
                "currency" => $currency,
                "pstore" => $pstore,
                "one_key" => $one_key,
                "one_hash" => $one_hash,
                "s_key" => $s_key,
                "s_hash" => $s_hash,
                "scredit" => $scredit,
                "rcredit" => $rcredit,
				"tax"=>$tax
            ];
            $where = "where id=" . $id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Setting Update Successfully!!",
                    "message" => "Offer section!",
                    "action" => "setting.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "setting.php",
                ];
            }
        }
    }
else if($_POST['type'] == 'add_sponsore')
{
	$okey = $_POST['status'];
	$commission = $_POST['commission'];
	$mobile = $_POST['mobile'];
	$email = $_POST['email'];
	$password = $_POST['password'];
	$title = $evmulti->real_escape_string($_POST['title']);
			$target_dir = dirname( dirname(__FILE__) )."/images/sponsore/";
			$url = "images/sponsore/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);

	$chek = $evmulti->query("select * from tbl_sponsore where email='".$email."'")->num_rows;
	if($chek!=0)
	{
		$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"Email Address Already Used!!","message"=>"Upload Problem!!","action"=>"add_sponsore.php");
	}
	else 
	{
	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_sponsore";
  $field_values=array("img","status","title","mobile","email","password","commission");
  $data_values=array("$url","$okey","$title","$mobile","$email","$password","$commission");
  
$h = new Event();
	  $check = $h->evmultiinsertdata($field_values,$data_values,$table);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Organizer Add Successfully!!","message"=>"Organizer section!","action"=>"list_sponsore.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_sponsore.php");
}
	}

}
else if($_POST['type'] == 'edit_sponsore')
{
	$okey = $_POST['status'];
	$commission = $_POST['commission'];
	$mobile = $_POST['mobile'];
	$email = $_POST['email'];
	$password = $_POST['password'];
	$id = $_POST['id'];
	$title = $evmulti->real_escape_string($_POST['title']);
			$target_dir = dirname( dirname(__FILE__) )."/images/sponsore/";
			$url = "images/sponsore/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);
$chek = $evmulti->query("select * from tbl_sponsore where email='".$email."' and id!=".$id."")->num_rows;
	if($chek!=0)
	{
		$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"Email Address Already Used!!","message"=>"Upload Problem!!","action"=>"add_sponsore.php");
	}
	else 
	{
if($_FILES["cat_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_sponsore";
  $field = array('status'=>$okey,'img'=>$url,'title'=>$title,'mobile'=>$mobile,'email'=>$email,'password'=>$password,'commission'=>$commission);
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Organizer Update Successfully!!","message"=>"Organizer section!","action"=>"list_sponsore.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_sponsore.php?id=".$id."");
}

}
else 
{
	$table="tbl_sponsore";
  $field = array('status'=>$okey,'title'=>$title,'mobile'=>$mobile,'email'=>$email,'password'=>$password,'commission'=>$commission);
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Organizer Update Successfully!!","message"=>"Organizer section!","action"=>"list_sponsore.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_sponsore.php?id=".$id."");
}
}
	}
}
else if($_POST['type'] == 'edit_ownprofile')
{
	$mobile = $_POST['mobile'];
	$email = $_POST['email'];
	$password = $_POST['password'];
	$id = $sdata['id'];
	$title = $evmulti->real_escape_string($_POST['title']);
			$target_dir = dirname( dirname(__FILE__) )."/images/sponsore/";
			$url = "images/sponsore/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);
$chek = $evmulti->query("select * from tbl_sponsore where email='".$email."' and id!=".$id."")->num_rows;
	if($chek!=0)
	{
		$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"Email Address Already Used!!","message"=>"Upload Problem!!","action"=>"oprofile.php");
	}
	else 
	{
if($_FILES["cat_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_sponsore";
  $field = array('img'=>$url,'title'=>$title,'mobile'=>$mobile,'email'=>$email,'password'=>$password);
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Profile Update Successfully!!","message"=>"Profile section!","action"=>"oprofile.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"oprofile.php");
}

}
else 
{
	$table="tbl_sponsore";
  $field = array('title'=>$title,'mobile'=>$mobile,'email'=>$email,'password'=>$password);
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Profile Update Successfully!!","message"=>"Profile section!","action"=>"oprofile.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"oprofile.php");
}
}
	}
}

elseif ($_POST["type"] == "add_facility") {
        $okey = $_POST["status"];
        $title = $evmulti->real_escape_string($_POST["title"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/facility/";
        $url = "images/facility/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        
            move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
            $table = "tbl_facility";
            $field_values = ["img", "status", "title"];
            $data_values = ["$url", "$okey", "$title"];

            $h = new Event();
            $check = $h->evmultiinsertdata($field_values, $data_values, $table);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Facility Add Successfully!!",
                    "message" => "Facility section!",
                    "action" => "list_facility.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_facility.php",
                ];
            }
        
    }
elseif ($_POST["type"] == "edit_facility") {
        $okey = $_POST["status"];
        $id = $_POST["id"];
        $title = $evmulti->real_escape_string($_POST["title"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/facility/";
        $url = "images/facility/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        if ($_FILES["cat_img"]["name"] != "") {
           
                move_uploaded_file(
                    $_FILES["cat_img"]["tmp_name"],
                    $target_file
                );
                $table = "tbl_facility";
                $field = ["status" => $okey, "img" => $url, "title" => $title];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Facility Update Successfully!!",
                        "message" => "Facility section!",
                        "action" => "list_facility.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "add_facility.php?id=" . $id . "",
                    ];
                }
            
        } else {
            $table = "tbl_facility";
            $field = ["status" => $okey, "title" => $title];
            $where = "where id=" . $id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Facility Update Successfully!!",
                    "message" => "Facility section!",
                    "action" => "list_category.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_facility.php?id=" . $id . "",
                ];
            }
        }
    }	
	elseif ($_POST["type"] == "add_restriction") {
        $okey = $_POST["status"];
        $title = $evmulti->real_escape_string($_POST["title"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/restriction/";
        $url = "images/restriction/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        
            move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
            $table = "tbl_restriction";
            $field_values = ["img", "status", "title"];
            $data_values = ["$url", "$okey", "$title"];

            $h = new Event();
            $check = $h->evmultiinsertdata($field_values, $data_values, $table);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Restriction Add Successfully!!",
                    "message" => "Restriction section!",
                    "action" => "list_restriction.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_restriction.php",
                ];
            }
        
    }
elseif ($_POST["type"] == "edit_restriction") {
        $okey = $_POST["status"];
        $id = $_POST["id"];
        $title = $evmulti->real_escape_string($_POST["title"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/restriction/";
        $url = "images/restriction/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        if ($_FILES["cat_img"]["name"] != "") {
            
                move_uploaded_file(
                    $_FILES["cat_img"]["tmp_name"],
                    $target_file
                );
                $table = "tbl_restriction";
                $field = ["status" => $okey, "img" => $url, "title" => $title];
                $where = "where id=" . $id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Restriction Update Successfully!!",
                        "message" => "Restriction section!",
                        "action" => "list_restriction.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "add_restriction.php?id=" . $id . "",
                    ];
                }
            
        } else {
            $table = "tbl_restriction";
            $field = ["status" => $okey, "title" => $title];
            $where = "where id=" . $id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Restriction Update Successfully!!",
                    "message" => "Restriction section!",
                    "action" => "list_restriction.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_restriction.php?id=" . $id . "",
                ];
            }
        }
    }
else if($_POST['type'] == 'add_events')
{
	$title = $evmulti->real_escape_string($_POST['title']);
	$address = $evmulti->real_escape_string($_POST['address']);
	$tags = $evmulti->real_escape_string($_POST['tags']);
	$vurls = $evmulti->real_escape_string($_POST['vurls']);
	$description = $evmulti->real_escape_string($_POST['cdesc']);
	$disclaimer = $evmulti->real_escape_string($_POST['disclaimer']);
	$status = $_POST['status'];
	$sponsore_id = $sdata['id'];
	$facility_id = implode(',',$_POST['facility_id']);
	$restict_id = implode(',',$_POST['restict_id']);
	$place_name = $evmulti->real_escape_string($_POST['pname']);
	$sdate = $_POST['sdate'];
	$stime = $_POST['stime'];
	$etime = $_POST['etime'];
	$cid = $_POST['cid'];
	$latitude = $_POST['latitude'];
	$longtitude = $_POST['longtitude'];
	
	$target_dir = dirname( dirname(__FILE__) )."/images/event/";
			$url = "images/event/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);

$target_dirs = dirname( dirname(__FILE__) )."/images/event/";
			$urls = "images/event/";
			$temps = explode(".", $_FILES["cover_img"]["name"]);
$newfilenames = uniqid().round(microtime(true)) . '.' . end($temps);
$target_files = $target_dirs . basename($newfilenames);
$urls = $urls . basename($newfilenames);


	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	move_uploaded_file($_FILES["cover_img"]["tmp_name"], $target_files);
	$table="tbl_event";
  $field_values=array("tags","vurls","cid","title","img","cover_img","sdate","stime","etime","address","status","description","disclaimer","latitude","longtitude","place_name","sponsore_id","facility_id","restict_id");
  $data_values=array("$tags","$vurls","$cid","$title","$url","$urls","$sdate","$stime","$etime","$address","$status","$description","$disclaimer","$latitude","$longtitude","$place_name","$sponsore_id","$facility_id","$restict_id");
  
$h = new Event();
	  $check = $h->evmultiinsertdata($field_values,$data_values,$table);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Event Add Successfully!!","message"=>"Event section!","action"=>"list_event.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_event.php");
}
	
}
else if($_POST['type'] == 'edit_event')
{
	$title = $evmulti->real_escape_string($_POST['title']);
	$id = $_POST['id'];
	$sponsore_id = $sdata['id'];
	$tags = $evmulti->real_escape_string($_POST['tags']);
	$vurls = $evmulti->real_escape_string($_POST['vurls']);
	$facility_id = (!isset($_POST['facility_id']))  ? '' : implode(',',$_POST['facility_id']);
	$restict_id = (!isset($_POST['restict_id']))  ? '' : implode(',',$_POST['restict_id']);
	$address = $evmulti->real_escape_string($_POST['address']);
	$description = $evmulti->real_escape_string($_POST['cdesc']);
	$disclaimer = $evmulti->real_escape_string($_POST['disclaimer']);
	$status = $_POST['status'];
	$place_name = $evmulti->real_escape_string($_POST['pname']);
	$sdate = $_POST['sdate'];
	$stime = $_POST['stime'];
	$etime = $_POST['etime'];
	$cid = $_POST['cid'];
	$latitude = $_POST['latitude'];
	$longtitude = $_POST['longtitude'];
	
	$target_dir = dirname( dirname(__FILE__) )."/images/event/";
			$url = "images/event/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);

$target_dirs = dirname( dirname(__FILE__) )."/images/event/";
			$urls = "images/event/";
			$temps = explode(".", $_FILES["cover_img"]["name"]);
$newfilenames = uniqid().round(microtime(true)) . '.' . end($temps);
$target_files = $target_dirs . basename($newfilenames);
$urls = $urls . basename($newfilenames);

if($_FILES["cat_img"]["name"] != '' and $_FILES["cover_img"]["name"] == '')
{

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_event";
  $field = array('tags'=>$tags,'vurls'=>$vurls,'place_name'=>$place_name,'facility_id'=>$facility_id,'restict_id'=>$restict_id,'status'=>$status,'img'=>$url,'title'=>$title,'cid'=>$cid,'sdate'=>$sdate,'stime'=>$stime,'etime'=>$etime,'address'=>$address,'description'=>$description,'disclaimer'=>$disclaimer,'latitude'=>$latitude,'longtitude'=>$longtitude);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateDatanull_Api($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Event Update Successfully!!","message"=>"Event section!","action"=>"list_event.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_event.php?id=".$id."");
}
}
else if($_FILES["cat_img"]["name"] == '' and $_FILES["cover_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cover_img"]["tmp_name"], $target_files);
	$table="tbl_event";
  $field = array('tags'=>$tags,'vurls'=>$vurls,'place_name'=>$place_name,'facility_id'=>$facility_id,'restict_id'=>$restict_id,'status'=>$status,'cover_img'=>$urls,'title'=>$title,'cid'=>$cid,'sdate'=>$sdate,'stime'=>$stime,'etime'=>$etime,'address'=>$address,'description'=>$description,'disclaimer'=>$disclaimer,'latitude'=>$latitude,'longtitude'=>$longtitude);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateDatanull_Api($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Event Update Successfully!!","message"=>"Event section!","action"=>"list_event.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_event.php?id=".$id."");
}
}
else if($_FILES["cat_img"]["name"] != '' and $_FILES["cover_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cover_img"]["tmp_name"], $target_files);
	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_event";
  $field = array('tags'=>$tags,'vurls'=>$vurls,'place_name'=>$place_name,'facility_id'=>$facility_id,'restict_id'=>$restict_id,'status'=>$status,'cover_img'=>$urls,'img'=>$url,'title'=>$title,'cid'=>$cid,'sdate'=>$sdate,'stime'=>$stime,'etime'=>$etime,'address'=>$address,'description'=>$description,'disclaimer'=>$disclaimer,'latitude'=>$latitude,'longtitude'=>$longtitude);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateDatanull_Api($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Event Update Successfully!!","message"=>"Event section!","action"=>"list_event.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_event.php?id=".$id."");
}
}
else 
{
	$table="tbl_event";
  $field = array('tags'=>$tags,'vurls'=>$vurls,'place_name'=>$place_name,'facility_id'=>$facility_id,'restict_id'=>$restict_id,'status'=>$status,'title'=>$title,'cid'=>$cid,'sdate'=>$sdate,'stime'=>$stime,'etime'=>$etime,'address'=>$address,'description'=>$description,'disclaimer'=>$disclaimer,'latitude'=>$latitude,'longtitude'=>$longtitude);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateDatanull_Api($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Event Update Successfully!!","message"=>"Event section!","action"=>"list_event.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_event.php?id=".$id."");
}
}
}
else if($_POST['type'] == 'add_type')
{
	$okey = $_POST['status'];
	$eid = $_POST['eid'];
	$etype = $evmulti->real_escape_string($_POST['etype']);
	$description = $evmulti->real_escape_string($_POST['description']);
	$price = $_POST['price'];
	$tlimit = $_POST['tlimit'];
	$sponsore_id = $sdata['id'];
	$table="tbl_type_price";
  $field_values=array("status","event_id","type","price","tlimit","sponsore_id","description");
  $data_values=array("$okey","$eid","$etype","$price","$tlimit","$sponsore_id","$description");
  
$h = new Event();
	  $check = $h->evmultiinsertdata($field_values,$data_values,$table);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Type & Price Add Successfully!!","message"=>"Type & Price section!","action"=>"list_etype.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_etype.php");
}

}
else if($_POST['type'] == 'edit_type')
{
	$okey = $_POST['status'];
	$eid = $_POST['eid'];
	$id = $_POST['id'];
	$description = $evmulti->real_escape_string($_POST['description']);
	$etype = $evmulti->real_escape_string($_POST['etype']);
	$price = $_POST['price'];
	$tlimit = $_POST['tlimit'];
	$sponsore_id = $sdata['id'];
	$table="tbl_type_price";
  $field = array('status'=>$okey,'price'=>$price,'event_id'=>$eid,'tlimit'=>$tlimit,'type'=>$etype,'description'=>$description);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Type & Price Edit Successfully!!","message"=>"Type & Price section!","action"=>"list_etype.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_etype.php?id=".$id."");
}

}
else if($_POST['type'] == 'add_cover')
{
	$okey = $_POST['status'];
	$sponsore_id = $sdata['id'];
	$eid = $_POST['eid'];
			$target_dir = dirname( dirname(__FILE__) )."/images/cover/";
			$url = "images/cover/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_cover";
  $field_values=array("img","status","eid","sponsore_id");
  $data_values=array("$url","$okey","$eid","$sponsore_id");
  
$h = new Event();
	  $check = $h->evmultiinsertdata($field_values,$data_values,$table);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Cover Image Add Successfully!!","message"=>"Cover Image section!","action"=>"list_cover.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_cover.php");
}
}
else if($_POST['type'] == 'edit_cover')
{
	$okey = $_POST['status'];
	$eid = $_POST['eid'];
	$sponsore_id = $sdata['id'];
	$id = $_POST['id'];
			$target_dir = dirname( dirname(__FILE__) )."/images/cover/";
			$url = "images/cover/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);
if($_FILES["cat_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_cover";
  $field = array('status'=>$okey,'img'=>$url,'eid'=>$eid);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Cover Image Update Successfully!!","message"=>"Cover Image section!","action"=>"list_cover.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_cover.php?id=".$id."");
}
}
else 
{
	$table="tbl_cover";
  $field = array('status'=>$okey,'eid'=>$eid);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Cover Image Update Successfully!!","message"=>"Cover Image section!","action"=>"list_cover.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_cover.php?id=".$id."");
}
}
}
else if($_POST['type'] == 'add_gallery')
{
	$okey = $_POST['status'];
	$eid = $_POST['eid'];
	$sponsore_id = $sdata['id'];
			$target_dir = dirname( dirname(__FILE__) )."/images/gallery/";
			$url = "images/gallery/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_gallery";
  $field_values=array("img","status","eid","sponsore_id");
  $data_values=array("$url","$okey","$eid","$sponsore_id");
  
$h = new Event();
	  $check = $h->evmultiinsertdata($field_values,$data_values,$table);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Gallery Add Successfully!!","message"=>"Gallery section!","action"=>"list_gallery.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_gallery.php");
}
}
else if($_POST['type'] == 'edit_gallery')
{
	$okey = $_POST['status'];
	$eid = $_POST['eid'];
	$sponsore_id = $sdata['id'];
	$id = $_POST['id'];
			$target_dir = dirname( dirname(__FILE__) )."/images/gallery/";
			$url = "images/gallery/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);
if($_FILES["cat_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_gallery";
  $field = array('status'=>$okey,'img'=>$url,'eid'=>$eid,'sponsore_id'=>$sponsore_id);
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Gallery Update Successfully!!","message"=>"Gallery section!","action"=>"list_gallery.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_gallery.php?id=".$id."");
}
}
else 
{
	$table="tbl_gallery";
  $field = array('status'=>$okey,'eid'=>$eid,'sponsore_id'=>$sponsore_id);
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Gallery Update Successfully!!","message"=>"Gallery section!","action"=>"list_gallery.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_gallery.php?id=".$id."");
}
}
}
else if($_POST['type'] == 'add_artist')
{
	$okey = $_POST['status'];
	$sponsore_id = $sdata['id'];
	$title = $evmulti->real_escape_string($_POST['aname']);
	$arole = $evmulti->real_escape_string($_POST['arole']);
	$eid = $_POST['eid'];
			$target_dir = dirname( dirname(__FILE__) )."/images/artist/";
			$url = "images/artist/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_artist";
  $field_values=array("img","status","eid","sponsore_id","arole","title");
  $data_values=array("$url","$okey","$eid","$sponsore_id","$arole","$title");
  
$h = new Event();
	  $check = $h->evmultiinsertdata($field_values,$data_values,$table);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Artist  Add Successfully!!","message"=>"Artist section!","action"=>"list_artist.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_artist.php");
}
}
else if($_POST['type'] == 'edit_artist')
{
	$okey = $_POST['status'];
	$eid = $_POST['eid'];
	$sponsore_id = $sdata['id'];
	$title = $evmulti->real_escape_string($_POST['aname']);
	$arole = $evmulti->real_escape_string($_POST['arole']);
	$id = $_POST['id'];
			$target_dir = dirname( dirname(__FILE__) )."/images/artist/";
			$url = "images/artist/";
			$temp = explode(".", $_FILES["cat_img"]["name"]);
$newfilename = round(microtime(true)) . '.' . end($temp);
$target_file = $target_dir . basename($newfilename);
$url = $url . basename($newfilename);
if($_FILES["cat_img"]["name"] != '')
{

	move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
	$table="tbl_artist";
  $field = array('status'=>$okey,'img'=>$url,'eid'=>$eid,'title'=>$title,'arole'=>$arole);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
  
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Artist Update Successfully!!","message"=>"Artist section!","action"=>"list_artist.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_artist.php?id=".$id."");
}
}
else 
{
	$table="tbl_artist";
  $field = array('status'=>$okey,'eid'=>$eid,'title'=>$title,'arole'=>$arole);
  $where = "where id=".$id." and sponsore_id=".$sponsore_id."";
$h = new Event();
	  $check = $h->evmultiupdateData($field,$table,$where);
	  if($check == 1)
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Artist Update Successfully!!","message"=>"Artist section!","action"=>"list_artist.php");
}
else 
{
	$returnArr = array("ResponseCode"=>"200","Result"=>"false","title"=>"For Demo purpose all  Insert/Update/Delete are DISABLED !!","message"=>"Operation DISABLED!!","action"=>"add_artist.php?id=".$id."");
}
}
}
elseif ($_POST["type"] == "add_coupon") {
        $expire_date = $_POST["expire_date"];
        $sponsore_id = $sdata["id"];
        $status = $_POST["status"];
        $coupon_code = $_POST["coupon_code"];
        $min_amt = $_POST["min_amt"];
        $coupon_val = $_POST["coupon_val"];
        $description = $evmulti->real_escape_string($_POST["description"]);
        $title = $evmulti->real_escape_string($_POST["title"]);
        $subtitle = $evmulti->real_escape_string($_POST["subtitle"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/coupon/";
        $url = "images/coupon/";
        $temp = explode(".", $_FILES["coupon_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        
            move_uploaded_file($_FILES["coupon_img"]["tmp_name"], $target_file);
            $table = "tbl_coupon";
            $field_values = [
                "expire_date",
                "status",
                "title",
                "sponsore_id",
                "coupon_code",
                "min_amt",
                "coupon_val",
                "description",
                "subtitle",
                "coupon_img",
            ];
            $data_values = [
                "$expire_date",
                "$status",
                "$title",
                "$sponsore_id",
                "$coupon_code",
                "$min_amt",
                "$coupon_val",
                "$description",
                "$subtitle",
                "$url",
            ];

            $h = new Event();
            $check = $h->evmultiinsertdata($field_values, $data_values, $table);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Coupon Add Successfully!!",
                    "message" => "Coupon section!",
                    "action" => "list_coupon.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_coupon.php",
                ];
            }
        
    } elseif ($_POST["type"] == "edit_coupon") {
        $expire_date = $_POST["expire_date"];
        $sponsore_id = $sdata["id"];
        $id = $_POST["id"];
        $status = $_POST["status"];
        $coupon_code = $_POST["coupon_code"];
        $min_amt = $_POST["min_amt"];
        $coupon_val = $_POST["coupon_val"];
        $description = $evmulti->real_escape_string($_POST["description"]);
        $title = $evmulti->real_escape_string($_POST["title"]);
        $subtitle = $evmulti->real_escape_string($_POST["subtitle"]);
        $target_dir = dirname(dirname(__FILE__)) . "/images/coupon/";
        $url = "images/coupon/";
        $temp = explode(".", $_FILES["coupon_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        if ($_FILES["coupon_img"]["name"] != "") {
            
                move_uploaded_file(
                    $_FILES["coupon_img"]["tmp_name"],
                    $target_file
                );
                $table = "tbl_coupon";
                $field = [
                    "status" => $status,
                    "coupon_img" => $url,
                    "title" => $title,
                    "coupon_code" => $coupon_code,
                    "min_amt" => $min_amt,
                    "coupon_val" => $coupon_val,
                    "description" => $description,
                    "subtitle" => $subtitle,
                    "expire_date" => $expire_date,
                ];
                $where =
                    "where id=" . $id . " and sponsore_id=" . $sponsore_id . "";
                $h = new Event();
                $check = $h->evmultiupdateData($field, $table, $where);

                if ($check == 1) {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "true",
                        "title" => "Coupon Update Successfully!!",
                        "message" => "Coupon section!",
                        "action" => "list_coupon.php",
                    ];
                } else {
                    $returnArr = [
                        "ResponseCode" => "200",
                        "Result" => "false",
                        "title" =>
                            "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                        "message" => "Operation DISABLED!!",
                        "action" => "add_coupon.php?id=" . $id . "",
                    ];
                }
            
        } else {
            $table = "tbl_coupon";
            $field = [
                "status" => $status,
                "title" => $title,
                "coupon_code" => $coupon_code,
                "min_amt" => $min_amt,
                "coupon_val" => $coupon_val,
                "description" => $description,
                "subtitle" => $subtitle,
                "expire_date" => $expire_date,
            ];
            $where = "where id=" . $id . " and sponsore_id=" . $sponsore_id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Coupon Update Successfully!!",
                    "message" => "Coupon section!",
                    "action" => "list_coupon.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "add_coupon.php?id=" . $id . "",
                ];
            }
        }
    }
elseif ($_POST["type"] == "update_status") {
        $id = $_POST["id"];
        $status = $_POST["status"];
        $coll_type = $_POST["coll_type"];
        $page_name = $_POST["page_name"];
         if ($coll_type == "userstatus") {
            $table = "tbl_user";
            $field = "status=" . $status . "";
            $where = "where id=" . $id . "";
            $h = new Event();
            $check = $h->evmultiupdateData_single($field, $table, $where);
            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "User Status Change Successfully!!",
                    "message" => "User section!",
                    "action" => "list_user.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "list_user.php",
                ];
            }
        }
		else if ($coll_type == "can_game") {
			$orag_id = $sdata["id"];
			$check_owner = $evmulti->query("select * from tbl_event where sponsore_id=" . $orag_id . " and id=".$id."")->num_rows;
if($check_owner != 0)
{
	$table="tbl_event";
  $field = "event_status='Cancelled'";
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData_single($field,$table,$where);
	  
	  $table="tbl_ticket";
  $field = "ticket_type='Cancelled'";
  $where = "where eid=".$id." and ticket_type='Booked'";
$h = new Event();
	   $h->evmultiupdateData_single($field,$table,$where);
	   
	   
	   $returnArr = array(
        "ResponseCode" => "200",
        "Result" => "true",
        "title" => "Event Successfully Cancelled!!",
		"message"=>"Event Successfully Cancelled!!",
		"action" => "list_event.php"
		);
	
	   $a = $evmulti->query("SELECT total_amt,eid,wall_amt,p_method_id,price FROM `tbl_ticket` where eid=".$id."");
	    while($row = $a->fetch_assoc())
	  {
		  $uid = $row['uid'];
		  
		  if($row['p_method_id'] == 11)
 {
	 
 }
else 
{
 if($row['p_method_id'] == 3)
	{
		$total_amt = $row['wall_amt'];
	}
	else {
		
	$total_amt = $row['total_amt']+$row['wall_amt'];
	}
	
	$vp = $evmulti->query("select wallet from tbl_user where id=".$uid."")->fetch_assoc();
	$mt = floatval($vp['wallet']) + floatval($total_amt);
  $table="tbl_user";
  $field = array('wallet'=>"$mt");
  $where = "where id=".$uid."";
$h = new Event();
	  $check = $h->evmultiupdateData_Api($field,$table,$where);
	  $timestamp = date("Y-m-d H:i:s");
	  $game = $evmulti->query("select title from tbl_event where id=".$id."")->fetch_assoc();
	  $table="wallet_report";
  $field_values=array("uid","message","status","amt","tdate");
  $data_values=array("$uid",'Refund Amount To Wallet Which Is Used For Booking Event '.$game['title'],'Credit',"$total_amt","$timestamp");
   
      $h = new Event();
	  $checks = $h->evmultiinsertdata_Api($field_values,$data_values,$table);
	  
	  }
	  
	  $udata = $evmulti->query("select name from tbl_user where id=".$uid."")->fetch_assoc();
          $name = $udata['name'];
		  
		  $content = array(
       "en" => $name.', Your Joined Event #'.$id.' Has Been Cancelled.'
   );
$heading = array(
   "en" => "Event Cancelled.!!"
);

$fields = array(
'app_id' => $set['one_key'],
'included_segments' =>  array("Active Users"),
'data' => array("event_id" =>$id,"status"=>"Cancelled"),
'filters' => array(array('field' => 'tag', 'key' => 'user_id', 'relation' => '=', 'value' => $uid)),
'contents' => $content,
'headings' => $heading
);
$fields = json_encode($fields);

 
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
curl_setopt($ch, CURLOPT_HTTPHEADER, 
array('Content-Type: application/json; charset=utf-8',
'Authorization: Basic '.$set['one_hash']));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($ch, CURLOPT_HEADER, FALSE);
curl_setopt($ch, CURLOPT_POST, TRUE);
curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
 
$response = curl_exec($ch);
curl_close($ch);


$timestamp = date("Y-m-d H:i:s");

 $title_mains = "Event Cancelled!!";
$descriptions = 'Event ID #'.$id.' Has Been Cancelled.';

	   $table="tbl_notification";
  $field_values=array("uid","datetime","title","description");
  $data_values=array("$uid","$timestamp","$title_mains","$descriptions");
  
    $h = new Eventmania();
	   $h->eventinsertdata_Api($field_values,$data_values,$table);
	   
	   
	}
}
else 
{
	$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
		"title" =>'You are Not Owner Of This Event!!',
        "message" => "You are Not Owner Of This Event!!",
		"action" =>"list_event.php"
    );
}

		}
		 else if ($coll_type == "com_game") {
			 
			 $orag_id = $sdata["id"];
			 $bn = $evmulti->query("select sum(`total_ticket`) as book_ticket from tbl_ticket where eid=".$id."  and ticket_type!='Cancelled'")->fetch_assoc();
		$bookticket = empty($bn['book_ticket']) ? 0 : $bn['book_ticket'];
		if($bookticket != 0)
		{
			 $check_owner = $evmulti->query("select * from tbl_event where sponsore_id=" . $orag_id . " and id=".$id."")->num_rows;
if($check_owner != 0)
{
	$table="tbl_event";
  $field = "event_status='Completed'";
  $where = "where id=".$id."";
$h = new Event();
	  $check = $h->evmultiupdateData_single($field,$table,$where);
	  
	  $table="tbl_ticket";
  $field = "ticket_type='Completed'";
  $where = "where eid=".$id." and ticket_type='Booked'";
$h = new Event();
	   $h->evmultiupdateData_single($field,$table,$where);
	   
	   $returnArr = array(
        "ResponseCode" => "200",
        "Result" => "true",
		"title"=>"Event Successfully Completed!",
        "message" => "Event Successfully Completed!",
		"action" =>"list_event.php"
    );
	
	   $a = $evmulti->query("SELECT uid,id FROM `tbl_ticket` where eid=".$id." and is_verify=1");
	  while($row = $a->fetch_assoc())
	  {
		  $uid = $row['uid'];
		  
		  $udata = $evmulti->query("select name from tbl_user where id=".$uid."")->fetch_assoc();
          $name = $udata['name'];
		  
		  $content = array(
       "en" => $name.', Your Joined Event #'.$id.' Has Been Completed.'
   );
$heading = array(
   "en" => "Event Completed. Now Provide Review About Event!!"
);

$fields = array(
'app_id' => $set['one_key'],
'included_segments' =>  array("Active Users"),
'data' => array("event_id" =>$id,"status"=>"Completed"),
'filters' => array(array('field' => 'tag', 'key' => 'user_id', 'relation' => '=', 'value' => $uid)),
'contents' => $content,
'headings' => $heading
);
$fields = json_encode($fields);

 
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
curl_setopt($ch, CURLOPT_HTTPHEADER, 
array('Content-Type: application/json; charset=utf-8',
'Authorization: Basic '.$set['one_hash']));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($ch, CURLOPT_HEADER, FALSE);
curl_setopt($ch, CURLOPT_POST, TRUE);
curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
 
$response = curl_exec($ch);
curl_close($ch);


$timestamp = date("Y-m-d H:i:s");

 $title_mains = "Event Completed!!";
$descriptions = 'Event ID #'.$id.' Has Been Completed.';

	   $table="tbl_notification";
  $field_values=array("uid","datetime","title","description");
  $data_values=array("$uid","$timestamp","$title_mains","$descriptions");
  
    $h = new Eventmania();
	   $h->eventinsertdata_Api($field_values,$data_values,$table);
	  }
	  
}
else 
{
	$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
		"title" =>'You are Not Owner Of This Event!!',
        "message" => "You are Not Owner Of This Event!!",
		"action" =>"list_event.php"
    );
}
		}
		else 
		{
		$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
		"title" =>'The event was not considered a complete event due to the lack of participation from anyone!!',
        "message" => "The event was not considered a complete event due to the lack of participation from anyone!!",
		"action" =>"list_event.php"
    );	
		}
		 }
        else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "title" => "Option Not There!!",
                "message" => "Error!!",
                "action" => "dashboard.php",
            ];
        }
    }	
else if($_POST['type'] == 'add_payout')
{
	$owner_id = $sdata["id"];
	$amt = $_POST['amt'];
	$r_type = $_POST['r_type'];
	$acc_number = $_POST['acc_number'];
	$bank_name = $_POST['bank_name'];
	$acc_name = $_POST['acc_name'];
	$ifsc_code = $_POST['ifsc_code'];
	$upi_id = $_POST['upi_id'];
	$paypal_id = $_POST['paypal_id'];
	
	$total_earn = $evmulti->query("select sum((subtotal-cou_amt) - ((subtotal-cou_amt) * commission/100)) as total_amt from tbl_ticket where sponsore_id=".$sdata["id"]." and ticket_type ='Completed'")->fetch_assoc();
	$earn =   empty($total_earn['total_amt']) ? 0 : number_format((float)($total_earn['total_amt']), 2, '.', '');
	
	$total_payout = $evmulti->query("select sum(amt) as total_payout from payout_setting where owner_id=".$sdata["id"]."")->fetch_assoc();
							  $payout =  empty($total_payout['total_payout']) ? 0 : number_format((float)($total_payout['total_payout']), 2, '.', '');
	
	$bs = 0;
				
				
				 if($finalearn == 0){}else {$bs = number_format((float)($earn)- $payout, 2, '.', ''); }
				 
				 if(floatval($amt) > floatval($set['pstore']))
				 {
					$returnArr = array("ResponseCode"=>"401","Result"=>"false","title"=>"You can't Payout Above Your Payout Limit!","message"=>"Payout Problem!!","action"=>"add_payout.php"); 
					
				 }
				 else if(floatval($amt) > floatval($bs))
				 {
					  
					 $returnArr = array("ResponseCode"=>"401","Result"=>"false","title"=>"You can't Payout Above Your Earning!","message"=>"Payout Problem!!","action"=>"add_payout.php"); 
				 }
				 else 
				 {
					 $timestamp = date("Y-m-d H:i:s");
					 $table="payout_setting";
  $field_values=array("owner_id","amt","status","r_date","r_type","acc_number","bank_name","acc_name","ifsc_code","upi_id","paypal_id");
  $data_values=array("$owner_id","$amt","pending","$timestamp","$r_type","$acc_number","$bank_name","$acc_name","$ifsc_code","$upi_id","$paypal_id");
  
      $h = new Event();
	  $check = $h->evmultiinsertdata_Api($field_values,$data_values,$table);
	  $returnArr = array("ResponseCode"=>"200","Result"=>"true","title"=>"Payout Request Submit Successfully!!","message"=>"Payout Submitted!!","action"=>"add_payout.php");
				 }
											   
}
elseif ($_POST["type"] == "com_payout") {
        $payout_id = $_POST["payout_id"];
        $target_dir = dirname(dirname(__FILE__)) . "/images/proof/";
        $url = "images/proof/";
        $temp = explode(".", $_FILES["cat_img"]["name"]);
        $newfilename = round(microtime(true)) . "." . end($temp);
        $target_file = $target_dir . basename($newfilename);
        $url = $url . basename($newfilename);
        
            move_uploaded_file($_FILES["cat_img"]["tmp_name"], $target_file);
            $table = "payout_setting";
            $field = ["proof" => $url, "status" => "completed"];
            $where = "where id=" . $payout_id . "";
            $h = new Event();
            $check = $h->evmultiupdateData($field, $table, $where);

            if ($check == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "title" => "Payout Update Successfully!!",
                    "message" => "Payout section!",
                    "action" => "list_payout.php",
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "false",
                    "title" =>
                        "For Demo purpose all  Insert/Update/Delete are DISABLED !!",
                    "message" => "Operation DISABLED!!",
                    "action" => "list_payout.php",
                ];
            }
        
    }	
}
echo json_encode($returnArr);