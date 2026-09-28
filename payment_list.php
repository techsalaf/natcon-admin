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
                  <div class="col-10">
                     <h3>
                        Payment Gateway Management
                     </h3>
                     <p class="blink_me">The wallet and free payment gateway
                       are not displayed here. Please do not enable them as this may cause errors,
                        as they are currently functioning in the background.</p>
                  </div>
                  <div class="col-2">
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
                                    <th>Sr No.</th>
                                    <th>Payment <br>Gateway <br>Image</th>
                                    <th>Payment <br>Gateway <br>Name</th>
                                    <th>Payment <br>Gateway <br>Subtitle</th>
                                    <th>Payment <br>Gateway <br>Status</th>
                                    <th>Show <br>On <br>Wallet?</th>
                                    <th>Action</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $stmt = $evmulti->query(
                                        "SELECT * FROM `tbl_payment_list` where id NOT IN(3,11)"
                                    );
                                    $i = 0;
                                    while ($row = $stmt->fetch_assoc()) {
                                        $i = $i + 1; ?>
                                 <tr>
                                    <td>
                                       <?php echo $i; ?>
                                    </td>
                                    <td class="align-middle">
                                       <img src="<?php echo $row[
                                          "img"
                                          ]; ?>" width="60" height="60" alt=""/>
                                    </td>
                                    <td> <?php echo $row[
                                       "title"
                                       ]; ?></td>
                                    <td style="max-width:200px;"> <?php echo $row["subtitle"]; ?></td>
                                    <?php if ($row["status"] == 1) { ?>
                                    <td><span class="badge badge-success">Publish</span></td>
                                    <?php } else { ?>
                                    <td>
                                       <span class="badge badge-danger">Unpublish</span>
                                    </td>
                                    <?php } ?>
                                    <?php if ($row["p_show"] == 1) { ?>
                                    <td><span class="badge badge-success">Publish</span></td>
                                    <?php } else { ?>
                                    <td>
                                       <span class="badge badge-danger">Unpublish</span>
                                    </td>
                                    <?php } ?>
                                    <td style="white-space: nowrap; width: 15%;">
                                       <div class="tabledit-toolbar btn-toolbar" style="text-align: left;">
                                          <div class="btn-group btn-group-sm" style="float: none;">
                                             <a href="edit_payment.php?id=<?php echo $row[
                                                "id"
                                                ]; ?>" class="badge badge-info"><i data-feather="edit-3"></i></a>
                                          </div>
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
