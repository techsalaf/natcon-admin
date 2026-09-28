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
                        Profile Management
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
                        <form method="post" enctype="multipart/form-data">
                           <div class="form-group mb-3">
                              <label>Organizer Image</label>
                              <input type="file" name="cat_img" class="form-control">
                              <input type="hidden" name="type" value="edit_ownprofile"/>
                              <input type="hidden" name="id" value="<?php echo $_GET["id"]; ?>"/>
                           </div>
                           <div class="form-group mb-3">
                              <img src="<?php echo $sdata["img"]; ?>" width="100px" height="100px" alt=""/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Name</label>
                              <input type="text" class="form-control input-rounded" value="<?php echo $sdata[
                                 "title"
                                 ]; ?>" name="title" placeholder="Enter Organizer Name"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Organizer Mobile</label>
                              <input type="text" class="form-control numberonly input-rounded"
                                value="<?php echo $sdata[
                                 "mobile"
                                 ]; ?>" name="mobile" placeholder="Enter Organizer mobile"  required="">
                           </div>
                           <div class="form-group mb-3">
                              <label>Email</label>
                              <input type="email" min="1" step="1"
                                class="form-control" name="email" required="" value="<?php echo $sdata[
                                 "email"
                                 ]; ?>">
                              <input type="hidden" name="id" value="1"/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Password</label>
                              <input type="text" min="1" step="1"
                                class="form-control" name="password" value="<?php echo $sdata[
                                 "password"
                                 ]; ?>" required="">
                           </div>
                           <div class="form-group mb-3">
                              <button type="submit" class="btn btn-primary mb-2">Edit Profile</button>
                           </div>
                     </div>
                     </form>
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
