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
                        Facility Management
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
                     <?php if (isset($_GET["id"])) {
                        $data = $evmulti
                            ->query(
                                "select * from tbl_facility where id=" .
                                    $_GET["id"] .
                                    ""
                            )
                            ->fetch_assoc(); ?>
                     <form method="post" enctype="multipart/form-data">
                        <div class="card-body">
                           <div class="form-group mb-3">
                              <label>Facility Name</label>
                              <input type="text" class="form-control" placeholder="Enter Title" value="<?php echo $data[
                                 "title"
                                 ]; ?>"name="title"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Facility Image</label>
                              <input type="file" class="form-control" name="cat_img" >
                              <br>
                              <img src="<?php echo $data["img"]; ?>" width="100px" alt=""/>
                              <input type="hidden" name="type" value="edit_facility"/>
                              <input type="hidden" name="id" value="<?php echo $_GET["id"]; ?>"/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Facility Status</label>
                              <select name="status" class="form-control" required>
                                 <option value="">Select Status</option>
                                 <option value="1" <?php if ($data["status"] == 1) {
                                    echo "selected";
                                    } ?>>Publish</option>
                                 <option value="0" <?php if ($data["status"] == 0) {
                                    echo "selected";
                                    } ?> >UnPublish</option>
                              </select>
                           </div>
                        </div>
                        <div class="card-footer text-left">
                           <button  class="btn btn-primary">Edit  Facility</button>
                        </div>
                     </form>
                     <?php
                        } else {
                             ?>
                     <form method="post" enctype="multipart/form-data">
                        <div class="card-body">
                           <div class="form-group mb-3">
                              <label>Facility Name</label>
                              <input type="text" class="form-control"
                               placeholder="Enter Title" name="title"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Facility Image</label>
                              <input type="file" class="form-control" name="cat_img"  required="">
                              <input type="hidden" name="type" value="add_facility"/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Facility Status</label>
                              <select name="status" class="form-control" required>
                                 <option value="">Select Status</option>
                                 <option value="1">Publish</option>
                                 <option value="0">UnPublish</option>
                              </select>
                           </div>
                        </div>
                        <div class="card-footer text-left">
                           <button  class="btn btn-primary">Add Facility</button>
                        </div>
                     </form>
                     <?php
                        } ?>
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
