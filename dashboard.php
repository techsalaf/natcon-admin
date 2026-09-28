<?php
   include "filemanager/head.php";
   define('SELC', 'select * from tbl_event where sponsore_id=');
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
                        Report Dashboard
                     </h3>
                     <p class="blink_me">The sale amount generated after completing an event,
                       and not from pending or cancelled events, generates sales.</p>
                  </div>
                  <div class="col-4">
                  </div>
               </div>
            </div>
         </div>
         <!-- Container-fluid starts-->
         <div class="container-fluid">
            <div class="row size-column">
               <?php if (isset($_SESSION["stype"])) {
                  if ($_SESSION["stype"] == "sowner") { ?>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              SELC.
                                  $sdata["id"] .
                                  ""
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Completed Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              SELC.
                                  $sdata["id"] .
                                  " and event_status='Completed'"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Cancelled Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              SELC.
                                  $sdata["id"] .
                                  " and event_status='Cancelled'"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Running Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              SELC.
                                  $sdata["id"] .
                                  " and event_status='Pending'"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Cover Images</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_cover where sponsore_id=" .
                                  $sdata["id"] .
                                  ""
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="image" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Gallery</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_gallery where sponsore_id=" .
                                  $sdata["id"] .
                                  ""
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="image" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Artist</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_artist where sponsore_id=" .
                                  $sdata["id"] .
                                  ""
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="users" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Coupon</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_coupon where sponsore_id=" .
                                  $sdata["id"] .
                                  ""
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="gift" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-3 col-5">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Ticket Sold</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php
                              $t = $evmulti
                                  ->query(
                                      "select sum(`total_ticket`) as totaltic from tbl_ticket where sponsore_id=" .
                                          $sdata["id"] .
                                          " and ticket_type!='Cancelled'"
                                  )
                                  ->fetch_assoc();
                              echo empty($t["totaltic"]) ? 0 : $t["totaltic"];
                              ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="pocket" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Earning</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php
                              $total_earn = $evmulti
                                  ->query(
                                      "select sum((subtotal-cou_amt) - ((subtotal-cou_amt) * commission/100))
                                       as total_amt from tbl_ticket where sponsore_id=" .
                                          $sdata["id"] .
                                          " and ticket_type ='Completed'"
                                  )
                                  ->fetch_assoc();
                              $earn = empty($total_earn["total_amt"])
                                  ? 0
                                  : number_format(
                                      (float) $total_earn["total_amt"],
                                      2,
                                      ".",
                                      ""
                                  );
                              echo $earn . $set["currency"];
                              ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="target" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Payout</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php
                              $total_payout = $evmulti
                                  ->query(
                                      "select sum(amt) as total_payout from payout_setting where owner_id=" .
                                          $sdata["id"] .
                                          ""
                                  )
                                  ->fetch_assoc();
                              $payout = empty($total_payout["total_payout"])
                                  ? 0
                                  : number_format(
                                      (float) $total_payout["total_payout"],
                                      2,
                                      ".",
                                      ""
                                  );
                              echo $payout . $set["currency"];
                              ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="thumbs-up" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">After Payout Earning</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo number_format((float) $earn - $payout, 2, ".", "") . $set["currency"]; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="target" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <?php } else { ?>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Category</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_category"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="list" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_event"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Completed Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_event where  event_status='Completed'"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Cancelled Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_event where  event_status='Cancelled'"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Running Events</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_event where  event_status='Pending'"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cast" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Pages</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_page"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="book-open" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total FAQ</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_faq"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="help-circle" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Payment Gateway</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_payment_list"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="database" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Organizer</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_sponsore"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="speaker" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Facility</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_facility"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="globe" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Restriction</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_restriction"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="shield-off" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Users</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php echo $evmulti->query(
                              "select * from tbl_user"
                              )->num_rows; ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="users" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Earning</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php
                              $total_earn = $evmulti
                                  ->query(
                                      "select sum((subtotal-cou_amt) * commission/100)
                                       as total_amt from tbl_ticket where  ticket_type ='Completed'"
                                  )
                                  ->fetch_assoc();
                              echo empty($total_earn["total_amt"]) ? 0
                                  : number_format((float) $total_earn["total_amt"], 2, ".", "") . $set["currency"];
                              ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="target" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Pending Payout</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php
                              $total_payout = $evmulti
                                  ->query(
                                      "select sum(amt) as total_payout from payout_setting where status='pending'"
                                  )
                                  ->fetch_assoc();
                              $payout = empty($total_payout["total_payout"])
                                  ? "0"
                                  : $total_payout["total_payout"];
                              echo $payout . $set["currency"];
                              ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="cloud-lightning" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-2">
                  <div class="card small-widget">
                     <div class="card-body warning">
                        <span class="f-light">Total Completed Payout</span>
                        <div class="d-flex align-items-end gap-1">
                           <h4><?php
                              $total_payout = $evmulti
                                  ->query(
                                      "select sum(amt) as total_payout from payout_setting  where status='completed'"
                                  )
                                  ->fetch_assoc();
                              $payout = empty($total_payout["total_payout"])
                                  ? "0"
                                  : $total_payout["total_payout"];
                              echo $payout . $set["currency"];
                              ?></h4>
                        </div>
                        <div class="bg-gradient">
                           <i data-feather="send" class="svg-fill"></i>
                        </div>
                     </div>
                  </div>
               </div>
               <?php }
                  } ?>
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
