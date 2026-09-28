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
                        User List Management
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
                                    <th></th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>mobile</th>
                                    <th>Join Date</th>
                                    <th>Status</th>
                                    <th>Refer Code</th>
                                    <th>Parent Code</th>
                                    <th>Wallet</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $stmt = $evmulti->query("SELECT * FROM `tbl_user`");
                                    $i = 0;
                                    while ($row = $stmt->fetch_assoc()) {
                                        $i = $i + 1; ?>
                                 <tr>
                                    <td>
                                       <?php if (
                                          !empty($row["pro_pic"])
                                          ) {
                                         
                                           ?>
                                       <img class="rounded-circle" width="35" height="35" src="<?php echo $row[
                                          "pro_pic"
                                          ]; ?>" alt="">
                                       <?php
                                          } ?>
                                    </td>
                                    <td><?php echo $row[
                                       "name"
                                       ]; ?></td>
                                    <td><?php echo $row["email"]; ?></td>
                                    <td><?php echo $row["mobile"]; ?></td>
                                    <td><?php echo $row["reg_date"]; ?></td>
                                    <?php if ($row["status"] == 1) { ?>
                                    <td><span  data-id="<?php echo $row[
                                       "id"
                                       ]; ?>" data-status="0" data-type="update_status"
                                        coll-type="userstatus" class="drop badge badge-danger">Make Deactive</span></td>
                                    <?php } else { ?>
                                    <td>
                                       <span data-id="<?php echo $row[
                                          "id"
                                          ]; ?>" data-status="1" data-type="update_status"
                                           coll-type="userstatus" class="badge drop  badge-success">Make Active</span>
                                    </td>
                                    <?php } ?>
                                    <td><?php echo $row["refercode"]; ?></td>
                                    <td><?php echo $row["parentcode"]; ?></td>
                                    <td><?php echo $row["wallet"] . $set["currency"]; ?></td>
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
