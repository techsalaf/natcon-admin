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
                        Event Cover Image Management
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
                  <?php if (isset($_GET["id"])) {
                     $data = $evmulti
                         ->query(
                             "select * from tbl_cover where id=" .
                                 $_GET["id"] .
                                 " and sponsore_id=" .
                                 $sdata["id"] .
                                 ""
                         )
                         ->fetch_assoc();
                     $count = $evmulti->query(
                         "select * from tbl_cover where id=" .
                             $_GET["id"] .
                             " and sponsore_id=" .
                             $sdata["id"] .
                             ""
                     )->num_rows;
                     if ($count != 0) { ?>
                  <div class="card">
                     <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                           <div class="form-group mb-3">
                              <label>Select Event</label>
                              <select name="eid" class="form-control select2-single" required>
                                 <option value="" disabled selected>Select Event</option>
                                 <?php
                                    $cat = $evmulti->query(
                                        "select * from tbl_event where sponsore_id=" . $sdata["id"] . ""
                                    );
                                    while ($row = $cat->fetch_assoc()) { ?>
                                 <option value="<?php echo $row["id"]; ?>" <?php if (
                                    $data["eid"] == $row["id"]
                                    ) {
                                    echo "selected";
                                    } ?>><?php echo $row["title"]; ?></option>
                                 <?php }
                                    ?>
                              </select>
                           </div>
                           <div class="form-group mb-3">
                              <label>Cover Image Image</label>
                              <input type="file" name="cat_img" class="form-control">
                              <input type="hidden" name="type" value="edit_cover"/>
                              <input type="hidden" name="id" value="<?php echo $_GET["id"]; ?>"/>
                           </div>
                           <div class="form-group">
                              <img src="<?php echo $data["img"]; ?>" width="100px" height="100px" alt=""/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Cover Image Status</label>
                              <select name="status" name="status" class="form-control input-rounded" required>
                                 <option value="">Select Status</option>
                                 <option value="1" <?php if ($data["status"] == 1) {
                                    echo "selected";
                                    } ?>>Publish</option>
                                 <option value="0" <?php if ($data["status"] == 0) {
                                    echo "selected";
                                    } ?>>UnPublish</option>
                              </select>
                           </div>
                           <div class="form-group">
                              <button type="submit" class="btn btn-rounded btn-primary">
                                <span class="btn-icon-start text-primary"><i class="fa fa-list"></i>
                              </span>Edit Cover Image</button>
                           </div>
                        </form>
                     </div>
                  </div>
                  <?php } else { ?>
                  <div class="card">
                     <div class="card-body text-center">
                        <h6>
                           Check Own Cover Images Or Add New Cover Images Of Below Click Button.
                        </h6>
                        <br>
                        <a href="add_cover.php" class="btn btn-primary">Add Cover Images</a>
                     </div>
                  </div>
                  <?php }
                     } else {
                          ?>
                  <div class="card">
                     <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                           <div class="form-group mb-3">
                              <label>Select Event</label>
                              <select name="eid" class="form-control select2-single" required>
                                 <option value="" disabled selected>Select Event</option>
                                 <?php
                                    $cat = $evmulti->query(
                                        "select * from tbl_event where sponsore_id=" . $sdata["id"] . ""
                                    );
                                    while ($row = $cat->fetch_assoc()) { ?>
                                 <option value="<?php echo $row["id"]; ?>"><?php echo $row["title"]; ?></option>
                                 <?php }
                                    ?>
                              </select>
                           </div>
                           <div class="form-group mb-3">
                              <label>Cover Image</label>
                              <input type="file" name="cat_img" class="form-control" required>
                              <input type="hidden" name="type" value="add_cover"/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Cover Image Status</label>
                              <select name="status" name="status" class="form-control input-rounded" required>
                                 <option value="">Select Status</option>
                                 <option value="1">Publish</option>
                                 <option value="0">UnPublish</option>
                              </select>
                           </div>
                           <div class="form-group">
                              <button type="submit" class="btn btn-rounded btn-primary">
                                <span class="btn-icon-start text-primary"><i class="fa fa-list"></i>
                              </span>Add Cover Image</button>
                           </div>
                        </form>
                     </div>
                  </div>
                  <?php
                     } ?>
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
