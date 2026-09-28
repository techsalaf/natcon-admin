<?php
require "evconfing.php";
$GLOBALS["evmulti"] = $evmulti;
class Event
{
  public function evmultilogin($username, $password, $tblname)
    {
        if ($tblname == "admin") {
            $q =
                "select * from " .
                $tblname .
                " where username='" .
                $username .
                "' and password='" .
                $password .
                "'";
            return $GLOBALS["evmulti"]->query($q)->num_rows;
        } else {
            $q =
                "select * from " .
                $tblname .
                " where email='" .
                $username .
                "' and password='" .
                $password .
                "'";
            return $GLOBALS["evmulti"]->query($q)->num_rows;
        }
    }

    public function evmultiinsertdata($field, $data, $table)
    {
        $field_values = implode(",", $field);
        $data_values = implode("','", $data);

        $sql = "INSERT INTO $table($field_values)VALUES('$data_values')";
        $result = $GLOBALS["evmulti"]->query($sql);
        return $result;
    }

    public function str_replace_first($search, $replace, $subject)
    {
        $search = "/" . preg_quote($search, "/") . "/";
        return preg_replace($search, $replace, $subject, 1);
    }

    public  function evmultizoneinsertdata($field, $data, $table)
    {
        $field_values = implode(",", $field);
        $data_values = implode("','", $data);
        $data_values =
            $this->str_replace_first("','", ",'", $data_values) . "'";
        $sql = "INSERT INTO $table($field_values)VALUES($data_values)";
        $result = $GLOBALS["evmulti"]->query($sql);
        return $result;
    }

    public function insmulti($field, $data, $table)
    {
        $field_values = implode(",", $field);
        $data_values = implode("','", $data);

        $sql = "INSERT INTO $table($field_values)VALUES('$data_values')";
        $result = $GLOBALS["evmulti"]->multi_query($sql);
        return $result;
    }

    

   

    

    public  function evmultiupdateData($field, $table, $where)
    {
        $cols = [];

        foreach ($field as $key => $val) {
            if ($val != null) {
                // check if value is not null then only add that colunm to array
                $cols[] = "$key = '$val'";
            }
        }
        $sql = "UPDATE $table SET " . implode(", ", $cols) . " $where";
 
        return $GLOBALS["evmulti"]->query($sql);
    }

    public  function evmultiupdateDatanullApi($field, $table, $where)
    {
        $cols = [];

        foreach ($field as $key => $val) {
            if ($val != null) {
                // check if value is not null then only add that colunm to array
                $cols[] = "$key = '$val'";
            } else {
                $cols[] = "$key = NULL";
            }
        }

        $sql = "UPDATE $table SET " . implode(", ", $cols) . " $where";
        $result = $GLOBALS["evmulti"]->query($sql);
        return $result;
    }

    public  function evmultizoneupdateData($field, $table, $where)
    {
        $cols = [];

        foreach ($field as $key => $val) {
            if ($val != null) {
                // check if value is not null then only add that colunm to array
                if ($key == "coordinates") {
                    $cols[] = "$key = $val";
                } else {
                    $cols[] = "$key = '$val'";
                }
            }
        }
        $sql = "UPDATE $table SET " . implode(", ", $cols) . " $where";
        $result = $GLOBALS["evmulti"]->query($sql);
        return $result;
    }

 

    public function evmultiupdateDatasingle($field, $table, $where)
    {
        $query = "UPDATE $table SET $field";

        $sql = $query . " " . $where;
        $result = $GLOBALS["evmulti"]->query($sql);
        return $result;
    }

    public  function evmultiDeleteData($where, $table)
    {
        $sql = "Delete From $table $where";
        $result = $GLOBALS["evmulti"]->query($sql);
        return $result;
    }

    
}

