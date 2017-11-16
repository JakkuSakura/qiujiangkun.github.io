<?php
/**
 * Created by PhpStorm.
 * User: QiuJiangkun
 * Date: 2017/11/9
 * Time: 16:37
 */
header("Access-Control-Allow-Origin: *");
//phpinfo();

//print_r($_POST);
$query = $_POST['query'];
//echo $query;

$con = mysqli_connect('localhost:3306', 'root', '', 'qjk_bird');

if (mysqli_connect_errno($con)) {
    die( $callback."([" . "Debugging errno: " . mysqli_connect_error() . "])");
}


//echo "Success: A proper connection to MySQL was made! The my_db database is great." . PHP_EOL . "<br />";
//echo "Host information: " . mysqli_get_host_info($con) . PHP_EOL . "<br />";

//执行该查询
$result = mysqli_query($con, $query) or die( $callback."([" . "Error in query: $query. " . mysqli_error($con) . "])");
//插入操作成功后，显示插入记录的记录号
//echo "记录已经插入， mysql_insert_id() = ". mysqli_insert_id($con) . "<br />";

//关闭当前数据库连接
$con->close();

$callback=$_GET['callback'];

if (!is_bool($result))
{
    if (mysqli_num_rows( $result ))
    {
        $res = json_encode(mysqli_fetch_row($result));

        while($row=mysqli_fetch_row($result))
        {
             $res = $res . "," . json_encode($row) ;
        }
    }
    else if (gettype($result) != "boolen")
    {
        die(mysqli_error($con));
    }
}
else
{
    $res = '"Succeeded"';
}
echo $callback."([$res])";
?>