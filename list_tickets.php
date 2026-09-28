<?php
   include "filemanager/head.php"; ?>
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
                  <div class="col-6">
                     <h3>
                        Ticket List Management
                     </h3>
                  </div>
                  <div class="col-6">
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
                        <?php
                           $checkownerevent = $evmulti->query(
                               "select * from tbl_event where id=" .
                                   $_GET["id"] .
                                   " and sponsore_id=" .
                                   $sdata["id"] .
                                   ""
                           )->num_rows;
                           if ($checkownerevent != 0) { ?>
                        <div class="table-responsive">
                           <table class="display" id="basic-1">
                              <thead>
                                 <tr>
                                    <th>Sr No.</th>
                                    <th>Ticket <br>Id.</th>
                                    <th>Event<br> Name</th>
                                    <th>Customer<br> Name</th>
                                    <th>Event <br>Type</th>
                                    <th>Event<br> Price</th>
                                    <th>Event <br>Subtotal</th>
                                    <th>Event <br>Coupon <br>Amount</th>
                                    <th>Total <br>Tickets</th>
                                    <th>Tax</th>
                                    <th>Wallet<br> Amount</th>
                                    <th>Total<br> Amount</th>
                                    <th>Payment?</th>
                                    <th>Status</th>
                                    <th>Cancel<br>Comment</th>
                                    <th>Review</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $city = $evmulti->query(
                                        "select * from tbl_ticket where eid=" .
                                            $_GET["id"] .
                                            " and sponsore_id=" .
                                            $sdata["id"] .
                                            ""
                                    );
                                    
                                    $i = 0;
                                    while ($row = $city->fetch_assoc()) {
                                    
                                        $i = $i + 1;
                                        $eve = $evmulti
                                            ->query(
                                                "SELECT title FROM `tbl_event` where id=" .
                                                    $row["eid"] .
                                                    ""
                                            )
                                            ->fetch_assoc();
                                        $user = $evmulti
                                            ->query(
                                                "SELECT name FROM `tbl_user` where id=" . $row["uid"] . ""
                                            )
                                            ->fetch_assoc();
                                        $pdata = $evmulti
                                            ->query(
                                                "select title from tbl_payment_list where id=" .
                                                    $row["p_method_id"] .
                                                    ""
                                            )
                                            ->fetch_assoc();
                                        ?>
                                 <tr>
                                    <td>
                                       <?php echo $i; ?>
                                    </td>
                                    <td> <?php echo $row["id"]; ?></td>
                                    <td> <?php echo $eve["title"]; ?></td>
                                    <td> <?php echo $user[
                                       "name"
                                       ]; ?></td>
                                    <td> <?php echo $row["type"]; ?></td>
                                    <td> <strong><?php echo $row["price"] . $set["currency"]; ?></strong></td>
                                    <td> <strong><?php echo $row["subtotal"] . $set["currency"]; ?></strong></td>
                                    <td> <strong><?php echo $row["cou_amt"] . $set["currency"]; ?></strong></td>
                                    <?php if ($row["total_ticket"] == 1) { ?>
                                    <td> <strong><?php echo $row["total_ticket"] . " Ticket"; ?></strong></td>
                                    <?php } else { ?>
                                    <td> <strong><?php echo $row["total_ticket"] . " Tickets"; ?></strong></td>
                                    <?php } ?>
                                    <td> <strong><?php echo $row["tax"] . $set["currency"]; ?></strong></td>
                                    <td> <strong><?php echo $row["wall_amt"] . $set["currency"]; ?></strong></td>
                                    <td> <strong><?php echo $row["total_amt"] . $set["currency"]; ?></strong></td>
                                    <?php if ($pdata["title"] == "Wallet" or $pdata["title"] == "Free") { ?>
                                    <td> <?php echo $pdata["title"]; ?></td>
                                    <?php } else { ?>
                                    <td> <?php echo $pdata["title"] .
                                       "<br><strong>" .
                                       $row["transaction_id"] .
                                       "</strong>"; ?></td>
                                    <?php } ?>
                                    <td>
                                       <?php if ($row["ticket_type"] == "Booked") { ?>
                                       <span class="badge badge-info"><?php echo $row["ticket_type"]; ?></span>
                                    </td>
                                    <?php } elseif ($row["ticket_type"] == "Completed") { ?>
                                    <span class="badge badge-success"><?php echo $row["ticket_type"]; ?></span></td>
                                    <?php } else { ?>
                                    <span class="badge badge-danger"><?php echo $row["ticket_type"]; ?></span></td>
                                    <?php } ?>
                                    <td> <?php echo $row["cancle_comment"]; ?></td>
                                    <?php if ($row["is_review"] == 0) { ?>
                                    <td> <?php echo "Review Not Done!"; ?></td>
                                    <?php } else { ?>
                                    <td> <?php echo $row["total_star"] . "-" . $row["review_comment"]; ?></td>
                                    <?php } ?>
                                 </tr>
                                 <?php
                                    }
                                    ?>
                              </tbody>
                           </table>
                        </div>
                        <?php } else { ?>
                        <h6>
                           Check Own Event Tickets Or Add New Event Of Below Click Button.
                        </h6>
                        <br>
                        <a href="add_event.php" class="btn btn-primary">Add Event</a>
                        <?php }
                           ?>
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
