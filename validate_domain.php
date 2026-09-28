<?php
   include "filemanager/head.php";
   // Bypass validation page when app is already activated
   if (isset($set['activated']) && $set['activated'] == 1) {
       if (isset($_SESSION["evename"])) {
           echo '<script>window.location.href="dashboard.php";</script>';
       } else {
           echo '<script>window.location.href="index.php";</script>';
       }
       exit;
   }
   if (isset($_SESSION["evename"])) { ?>
<script>
   window.location.href="dashboard.php";
</script>
<?php } ?>
<!-- login page start-->
<div class="container-fluid">
   <div class="row">
      <div class="col-xl-5"><img class="bg-img-cover bg-center" src="images/bg.jpg" alt="looginpage"></div>
      <div class="col-xl-7 p-0">
         <div class="login-card login-dark">
            <div>
               <div><a class="logo text-center" href="javascript:void(0);">
                <img class="img-fluid for-light" src="<?php echo $set[
                  "weblogo"
                  ]; ?>" alt="looginpage"><img class="img-fluid for-dark" src="<?php echo $set[
                  "weblogo"
                  ]; ?>" alt="looginpage"></a></div>
               <div class="login-main">
                  <div class="theme-form">
                     <h4>Validate Domain</h4>
                     <p>Welcome back! Validate your account.</p>
                     <div id="getmsg"></div>
                     <div class="form-group">
                        <label class="col-form-label">Enter Envato Purchase Code</label>
                        <input class="form-control" type="text" required=""
                         name="inputCode" id="inputCode" placeholder="Enter  Enavato Purchase Code">
                     </div>
                     <div class="form-group mb-0">
                        <button class="btn btn-primary btn-block w-100" id="sub_activate">
                          Activate &amp; Enjoy Our Service</button>
                     </div>
                  </div>
               </div>
            </div>
         </div>
      </div>
   </div>
   <?php include "filemanager/script.php"; ?>
</div>
</body>
</html>
