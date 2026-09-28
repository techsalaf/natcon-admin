<?php
   include "filemanager/head.php";
 define('COM', " and ticket_type ='Completed'");
   ?>
<!-- loader ends-->
<!-- tap on top starts-->
<div class="tap-top"><i data-feather="chevrons-up"></i></div>
<!-- tap on tap ends-->
<!-- page-wrapper Start-->
<div class="page-wrapper compact-wrapper" id="pageWrapper">
   <!-- Page Header Start-->
   <?php include "filemanager/navbar.php"; ?>
   <!-- Page Header Ends                              -->
   <!-- Page Body Start-->
   <div class="page-body-wrapper">
      <!-- Page Sidebar Start-->
      <?php include "filemanager/sidebar.php"; ?>
      <!-- Page Sidebar Ends-->
      <div class="page-body">
         <div class="container-fluid">
            <div class="page-title">
               <div class="row">
                  <div class="col-8">
                     <h3>
                        Organizer List Management
                     </h3>
                     <p class="blink_me">The sale amount generated after completing
                        an event, and not from pending or cancelled events, generates sales.
                     </p>
                  </div>
                  <div class="col-8">
                  </div>
               </div>
            </div>
         </div>
         <!-- Container-fluid starts-->
         <div class="container-fluid">
            <div class="row size-column">
               <div class="col-sm-12">
                  <div class="card">
                     <div class="card-body">
                        <div class="table-responsive">
                           <table id="basic-1" class="display" style="min-width: 845px">
                              <thead>
                                 <tr>
                                    <th>Sr No.</th>
                                    <th>Organizer Image</th>
                                    <th>Organizer Title</th>
                                    <th>Total Organize Event</th>
                                    <th>Total Running Event</th>
                                    <th>Total Completed Event</th>
                                    <th>Total Cancelled Event</th>
                                    <th>Total Event Sales</th>
                                    <th>Total Event Coupon Amount Used</th>
                                    <th>Total Hand Sales</th>
                                    <th>Total Your Commission</th>
                                    <th>Total Payout Pending</th>
                                    <th>Total Payout Completed</th>
                                    <th>Remain Oragnizer Earning</th>
                                    <th>Organizer Status</th>
                                    <th>Action</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $city = $evmulti->query(
                                        "select * from tbl_sponsore"
                                    );
                                    $i = 0;
                                    while (
                                        $row = $city->fetch_assoc()
                                    ) {
                                        $i = $i + 1; ?>
                                 <tr>
                                    <td>
                                       <?php echo $i; ?>
                                    </td>
                                    <td class="align-middle">
                                       <img src="<?php echo $row[
                                          "img"
                                          ]; ?>" width="50" height="50" alt=""/>
                                    </td>
                                    <td>
                                       <?php echo $row["title"]; ?>
                                    </td>
                                    <td>
                                       <?php echo "<b>" .
                                          $evmulti->query(
                                              "select * from tbl_event where sponsore_id=" .
                                                  $row["id"] .
                                                  ""
                                          )->num_rows .
                                          " Event Oragnize</b>"; ?>
                                    </td>
                                    <td>
                                       <?php echo $evmulti->query(
                                          "select * from tbl_event where  event_status='Pending' and sponsore_id=" .
                                              $row["id"] .
                                              ""
                                          )->num_rows; ?>
                                    </td>
                                    <td>
                                       <?php echo $evmulti->query(
                                          "select * from tbl_event where  event_status='Completed' and sponsore_id=" .
                                              $row["id"] .
                                              ""
                                          )->num_rows; ?>
                                    </td>
                                    <td>
                                       <?php echo $evmulti->query(
                                          "select * from tbl_event where  event_status='Cancelled' and sponsore_id=" .
                                              $row["id"] .
                                              ""
                                          )->num_rows; ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_earn = $evmulti
                                              ->query(
                                          "select sum(subtotal) as total_amt from tbl_ticket where sponsore_id=" .
                                                      $row["id"] .
                                                      COM
                                              )
                                              ->fetch_assoc();
                                          $earn = empty($total_earn["total_amt"])
                                              ? 0
                                              : number_format((float) $total_earn["total_amt"], 2, ".", "");
                                          echo $earn . $set["currency"];
                                          ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_earn = $evmulti
                                              ->query(
                                          "select sum(cou_amt) as total_amt from tbl_ticket where sponsore_id=" .
                                                      $row["id"] .
                                                      COM
                                              )
                                              ->fetch_assoc();
                                          $earn = empty($total_earn["total_amt"])
                                              ? 0
                                              : number_format((float) $total_earn["total_amt"], 2, ".", "");
                                          echo $earn . $set["currency"];
                                          ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_earn = $evmulti
                                              ->query(
                                          "select sum(subtotal-cou_amt) as total_amt
 from tbl_ticket where sponsore_id=" .
                                                      $row["id"] .
                                                      COM
                                              )
                                              ->fetch_assoc();
                                          $earn = empty($total_earn["total_amt"])
                                              ? 0
                                              : number_format((float) $total_earn["total_amt"], 2, ".", "");
                                          echo $earn . $set["currency"];
                                          ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_earn = $evmulti
                                              ->query(
                                          "select sum((subtotal-cou_amt) * commission/100) as total_amt from tbl_ticket
                                          where sponsore_id=" .
                                                      $row["id"] .
                                                      COM
                                              )
                                              ->fetch_assoc();
                                          $earn = empty($total_earn["total_amt"])
                                              ? 0
                                              : number_format((float) $total_earn["total_amt"], 2, ".", "");
                                          echo $earn . $set["currency"];
                                          ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_payout = $evmulti
                                              ->query(
                                                  "select sum(amt) as total_payout from payout_setting
                                          where status='pending'
                                          and owner_id=" .
                                                      $row["id"] .
                                                      ""
                                              )
                                              ->fetch_assoc();
                                          $payouts = empty($total_payout["total_payout"])
                                              ? "0"
                                              : $total_payout["total_payout"];
                                          echo $payouts . $set["currency"];
                                          ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_payout = $evmulti
                                              ->query(
                                          "select sum(amt) as total_payout from
 payout_setting where status='completed' and owner_id=" .
                                                      $row["id"] .
                                                      ""
                                              )
                                              ->fetch_assoc();
                                          $payout = empty($total_payout["total_payout"])
                                              ? "0"
                                              : $total_payout["total_payout"];
                                          echo $payout . $set["currency"];
                                          ?>
                                    </td>
                                    <td>
                                       <?php
                                          $total_payout = $evmulti
                                              ->query(
                                                  "select sum(amt) as total_payout from
  payout_setting where owner_id=" .
                                                      $row["id"] .
                                                      ""
                                              )
                                              ->fetch_assoc();
                                          $payouts = empty($total_payout["total_payout"])
                                              ? 0
                                              : number_format(
                                                  (float) $total_earn["total_payout"],
                                                  2,
                                                  ".",
                                                  ""
                                              );
                                          
                                          $total_earn = $evmulti
                                              ->query(
                                                  "select sum((subtotal-cou_amt)
  - ((subtotal-cou_amt) * commission/100))
 as total_amt from tbl_ticket where sponsore_id=" .
                                                      $row["id"] .
                                                      COM
                                              )
                                              ->fetch_assoc();
                                          $earns = empty($total_earn["total_amt"])
                                              ? 0
                                              : number_format((float) $total_earn["total_amt"], 2, ".", "");
                                          
                                          echo number_format((float) $earns - $payouts, 2, ".", "") .
                                              $set["currency"];
                                          ?>
                                    </td>
                                    <?php if ($row["status"] == 1) { ?>
                                    <td><span class="badge badge-success">Publish</span></td>
                                    <?php } else { ?>
                                    <td>
                                       <span class="badge badge-danger">Unpublish</span>
                                    </td>
                                    <?php } ?>
                                    <td>
                                       <div class="d-flex">
                                          <a href="add_sponsore.php?id=<?php echo $row[
                                             "id"
                                             ]; ?>" class="badge badge-info"><i data-feather="edit-3"></i></a>
                                       </div>
                                    </td>
                                 </tr>
                                 <?php
                                    }
                                    ?>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
         <!-- Container-fluid Ends-->
      </div>
      <!-- footer start-->
   </div>
</div>
<?php include "filemanager/script.php"; ?>
<!-- Plugin used-->
</body>
</html>
