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
                        Payout List Management
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
                        <div class="table-responsive">
                           <table class="display" id="basic-1">
                              <thead>
                                 <tr>
                                    <th class="text-center">
                                       #
                                    </th>
                                    <th>Transfer Photo</th>
                                    <th>Amount</th>
                                    <th>Transfer Details</th>
                                    <th>Transfer Type</th>
                                    <th>Status</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $stmt = $evmulti->query(
                                        "SELECT * FROM `payout_setting` where owner_id=" .
                                            $sdata["id"] .
                                            ""
                                    );
                                    $i = 0;
                                    while (
                                        $row = $stmt->fetch_assoc()
                                    ) {
                                        $i = $i + 1; ?>
                                 <tr>
                                    <td>
                                       <?php echo $i; ?>
                                    </td>
                                    <?php if (
                                       $row["proof"] == ""
                                       ) { ?>
                                    <td></td>
                                    <?php } else { ?>
                                    <td><img src="<?php echo $row["proof"]; ?>" width="70" height="80" alt=""/></td>
                                    <?php } ?>
                                    <td><?php echo $row["amt"] .
                                       " " .
                                       $set["currency"]; ?></td>
                                    <?php if ($row["r_type"] == "UPI") { ?>
                                    <td><?php echo $row["upi_id"]; ?></td>
                                    <?php } elseif ($row["r_type"] == "BANK Transfer") { ?>
                                    <td><?php echo "Bank Name: " .
                                       $row["bank_name"] .
                                       "<br>" .
                                       "A/C No: " .
                                       $row["acc_number"] .
                                       "<br>" .
                                       "A/C Name: " .
                                       $row["receipt_name"] .
                                       "<br>" .
                                       "IFSC CODE: " .
                                       $row["ifsc"] .
                                       "<br>"; ?></td>
                                    <?php } else { ?>
                                    <td><?php echo $row["paypal_id"]; ?></td>
                                    <?php } ?>
                                    <td><?php echo $row["r_type"]; ?></td>
                                    <td><span class="badge badge-success"><?php echo ucfirst(
                                       $row["status"]
                                       ); ?></span></td>
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
