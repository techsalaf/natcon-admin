<?php
include 'evconfing.php';
?>
<!DOCTYPE html> 
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="<?php echo $set['weblogo'];?>" type="image/x-icon">
    <link rel="shortcut icon" href="<?php echo $set['weblogo'];?>" type="image/x-icon">
    <title><?php echo $set['webname'];?> - Admin Panel</title>
    <!-- Google font-->
    <link href="https://fonts.googleapis.com/css?family=Rubik:400,400i,500,500i,700,700i&amp;display=swap" rel="stylesheet">
    
    
    <!-- ico-font-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/icofont.css">
    <!-- Themify icon-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/themify.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/datatables.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/datatable-extension.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/animate.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/aos.css">
    
    <!-- Flag icon-->
    
    <!-- Feather icon-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/feather-icon.css">
    <!-- Plugins css start-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/slick.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/slick-theme.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/scrollbar.css">
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/select2.css">
    <!-- Plugins css Ends-->
    <!-- Bootstrap css-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/vendors/bootstrap.css">
  	<link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/bootstrap-tagsinput/bootstrap-tagsinput.css">
    <!-- App css-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/style.css">
	
  <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/summernote/summernote-bs4.css">
    
    <!-- Responsive css-->
    <link rel="stylesheet" type="text/css" href="<?php echo $base; ?>/assets/css/responsive.css">
    <!-- Adjust legacy grid: make existing `col-2` match original dashboard sizing -->
    <style>
      .page-header .header-logo-wrapper .logo-wrapper img,
      .sidebar-wrapper .logo-wrapper > a > img,
      .sidebar-wrapper .back-btn > a > img,
      .login-main .logo img {
        width: auto;
        height: auto;
        max-width: 140px;
        max-height: 40px;
        object-fit: contain;
      }
      .sidebar-wrapper .logo-icon-wrapper img {
        width: 40px;
        height: 40px;
        object-fit: contain;
      }
      /* On large screens behave like col-lg-3 (25%) */
      @media (min-width: 992px) {
        .col-2 { flex: 0 0 25%; max-width: 25%; }
      }
      /* On smaller screens approximate col-5 (~41.6667%) */
      @media (max-width: 991.98px) {
        .col-2 { flex: 0 0 41.666667%; max-width: 41.666667%; }
      }
    </style>
  </head>
  <body>
    <!-- loader starts-->
    <div class="loader-wrapper">
      <div class="loader"></div>
      
    </div>
