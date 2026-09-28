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
                        Organizer Management
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
               <div class="col-xl-12 col-lg-12">
                  <?php if (isset($_GET["id"])) {
                     $data = $evmulti
                         ->query("select * from tbl_sponsore where id=" . $_GET["id"] . "")
                         ->fetch_assoc(); ?>
                  <div class="card">
                     <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                           <div class="form-group mb-3">
                              <label>Organizer Image</label>
                              <input type="file" name="cat_img" class="form-control">
                              <input type="hidden" name="type" value="edit_sponsore"/>
                              <input type="hidden" name="id" value="<?php echo $_GET["id"]; ?>"/>
                           </div>
                           <div class="form-group mb-3">
                              <img src="<?php echo $data["img"]; ?>" width="100px" height="100px" alt=""/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Name</label>
                              <input type="text" class="form-control input-rounded" value="<?php echo $data[
                                 "title"
                                 ]; ?>" name="title" placeholder="Enter Organizer Name"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Mobile</label>
                              <input type="text" class="form-control mobile input-rounded"  value="<?php echo $data[
                                 "mobile"
                                 ]; ?>" name="mobile" placeholder="Enter Organizer mobile"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Email</label>
                              <input type="text" class="form-control  input-rounded" value="<?php echo $data[
                                 "email"
                                 ]; ?>" name="email" placeholder="Enter Organizer Email"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Password</label>
                              <input type="text" class="form-control  input-rounded" value="<?php echo $data[
                                 "password"
                                 ]; ?>"  name="password" placeholder="Enter Organizer Password"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Commission</label>
                              <input type="number" step="0.01" class="form-control  input-rounded"
                                value="<?php echo $data[
                                 "commission"
                                 ]; ?>" name="commission" placeholder="Enter Commission"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Status</label>
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
                              </span>Edit Organizer</button>
                           </div>
                        </form>
                     </div>
                  </div>
                  <?php
                     } else {
                          ?>
                  <div class="card">
                     <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                           <div class="form-group mb-3">
                              <label>Organizer Image</label>
                              <input type="file" name="cat_img" class="form-control" required>
                              <input type="hidden" name="type" value="add_sponsore"/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Name</label>
                              <input type="text" class="form-control input-rounded"
                                name="title" placeholder="Enter Organizer Name"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Mobile</label>
                              <input type="text" class="form-control mobile input-rounded"
                               name="mobile" placeholder="Enter Organizer mobile"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Email</label>
                              <input type="text" class="form-control  input-rounded"
                                name="email" placeholder="Enter Organizer Email"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Password</label>
                              <input type="password" class="form-control  input-rounded"
                                name="password" placeholder="Enter Organizer Password"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Commission</label>
                              <input type="number" step="0.01" class="form-control  input-rounded"
                                name="commission" placeholder="Enter Commission"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Status</label>
                              <select name="status" name="status" class="form-control input-rounded" required>
                                 <option value="">Select Status</option>
                                 <option value="1">Publish</option>
                                 <option value="0">UnPublish</option>
                              </select>
                           </div>
                           <div class="form-group">
                              <button type="submit" class="btn btn-rounded btn-primary">
                                <span class="btn-icon-start text-primary"><i class="fa fa-list"></i>
                              </span>Add Organizer</button>
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
