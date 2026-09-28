<?php
include_once "filemanager/head.php"; ?>
    <!-- loader ends-->
    <!-- tap on top starts-->
    <div class="tap-top"><i data-feather="chevrons-up"></i></div>
    <!-- tap on tap ends-->
    <!-- page-wrapper Start-->
    <div class="page-wrapper compact-wrapper" id="pageWrapper">
      <!-- Page Header Start-->
<?php include_once "filemanager/navbar.php"; ?>
      <!-- Page Header Ends                              -->
      <!-- Page Body Start-->
      <div class="page-body-wrapper">
        <!-- Page Sidebar Start-->
        <?php include_once "filemanager/sidebar.php"; ?>
        <!-- Page Sidebar Ends-->
        <div class="page-body">
          <div class="container-fluid">
            <div class="page-title">
              <div class="row">
                <div class="col-6">
                  <h3>
                     Event Artist  Management</h3>
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
                            "select * from tbl_artist
 where id=" .
                                $_GET["id"] .
                                "
  and sponsore_id=" .
                                $sdata["id"] .
                                ""
                        )
                        ->fetch_assoc();
                    $count = $evmulti->query(
                        "select * from tbl_artist
 where id=" .
                            $_GET["id"] .
                            "
and sponsore_id=" .
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
} ?>>
                        <?php echo $row["title"]; ?>
                      </option>
<?php }
           ?>
</select>
                                        </div>

                                        <div class="form-group mb-3">
                                            <label>Artist Image Image</label>
                                           
                                                <input type="file" name="cat_img" class="form-control">
<input type="hidden" name="type" value="edit_artist"/>
<input type="hidden" name="id" value="<?php echo $_GET["id"]; ?>"/>
                                            
                                        </div>
<div class="form-group mb-3">
<img src="<?php echo $data["img"]; ?>" width="100px" height="100px" alt=""/>
</div>

<div class="form-group mb-3">
                                   
                                        <label  id="basic-addon1">Artist Name</label>
                                    
                                  <input type="text"
                                  class="form-control"
                                   placeholder="Enter Artist Name"
                                     name="aname" aria-label="Username"
                                      value="<?php echo $data["title"]; ?>"
                                       aria-describedby="basic-addon1" required>
                            
</div>
<div class="form-group mb-3">
                                   
                                        <label  id="basic-addon1">Artist Role</label>
                                    
                                  <input type="text"
                                   class="form-control"
                                    placeholder="Enter Answer"
                                      name="arole" aria-label="Username"
                                       value="<?php echo $data["arole"]; ?>"
                                         aria-describedby="basic-addon1" required>
                               
</div>
<div class="form-group mb-3">
                                            <label>Artist Status</label>
                                            <select name="status"
                                             name="status"
                                              class="form-control input-rounded"
                                               required>
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
                                        <button type="submit"
                                         class="btn btn-rounded btn-primary">
                                         <span class="btn-icon-start text-primary">
                                          <i class="fa fa-list"></i>
                                    </span>Edit Artist</button>
                                    </div>
                                </form>
                               
                            </div>
                        </div>
<?php } else { ?>
<div class="card">
<div class="card-body text-center">

 <h6>
 Check Own Artist Or Add New Artist Of Below Click Button.
 </h6>
 <br>
<a href="add_artist.php" class="btn btn-primary">Add Artist</a>
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
                                            <label>Artist Image</label>
                                           
                                                <input type="file" name="cat_img" class="form-control" required>
<input type="hidden" name="type" value="add_artist"/>
                                            
                                        </div>

<div class="form-group mb-3">
                                   
                                        <label  id="basic-addon1">Artist Name</label>
                                    
                                  <input type="text" class="form-control"
                                   placeholder="Enter Artist Name"  name="aname"
                                    aria-label="Username" aria-describedby="basic-addon1"
                                     required>
                            
</div>

<div class="form-group mb-3">
                                   
                                        <label  id="basic-addon1">Artist Role</label>
                                    
                                  <input type="text" class="form-control"
                                   placeholder="Enter Answer"  name="arole" aria-label="Username"
                                    aria-describedby="basic-addon1" required>
                               
</div>

<div class="form-group mb-3">
                                            <label>Artist Status</label>
                                            <select name="status" name="status"
                                             class="form-control input-rounded" required>
<option value="">Select Status</option>
<option value="1">Publish</option>
<option value="0">UnPublish</option>
</select>
                                        </div>
                                        
                                    
                                    <div class="form-group">
                                        <button type="submit" class="btn btn-rounded btn-primary">
                                          <span class="btn-icon-start text-primary">
                                            <i class="fa fa-list"></i>
                                    </span>Add Artist</button>
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
    <?php include_once "filemanager/script.php"; ?>
    
    <!-- Plugin used-->
    
  </body>
</html>
