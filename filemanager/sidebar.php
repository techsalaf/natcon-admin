<?php
   if (!isset($_SESSION["evename"])) {
   
        ?>
<script>
   window.location.href="/";
</script>
<?php
   }
   if ($_SESSION["stype"] == "mowner") { ?>
<div class="sidebar-wrapper" sidebar-layout="stroke-svg">
   <div>
      <div class="logo-wrapper">
         <a href="dashboard.php"><img class="img-fluid for-light" src="<?php echo $set[
            "weblogo"
            ]; ?>" alt=""><img class="img-fluid for-dark" src="<?php echo $set[
            "weblogo"
            ]; ?>" alt=""></a>
         <div class="back-btn"><i class="fa fa-angle-left"></i></div>
         <div class="toggle-sidebar"><i class="status_toggle middle sidebar-toggle" data-feather="grid"> </i></div>
      </div>
      <div class="logo-icon-wrapper"><a href="dashboard.php"><img class="img-fluid" src="<?php echo $set[
         "weblogo"
         ]; ?>" width="50px" alt=""></a></div>
      <nav class="sidebar-main" aria-label="">
         <div class="left-arrow" id="left-arrow"><i data-feather="arrow-left"></i></div>
         <div id="sidebar-menu">
            <ul class="sidebar-links" id="simple-bar">
               <li class="back-btn">
                  <a href="dashboard.php"><img class="img-fluid" src="<?php echo $set[
                     "weblogo"
                     ]; ?>" alt=""></a>
                  <div class="mobile-back text-end">
                    <span>Back</span><i class="fa fa-angle-right ps-2" aria-hidden="true"></i></div>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6 class="lan-1">General</h6>
                  </div>
               </li>
               <li class="sidebar-list"><a class="sidebar-link sidebar-title link-nav" href="dashboard.php">
                  <i data-feather="home"></i><span>DashBoard</span></a>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="list"></i><span >Category</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_category.php">Add Category</a></li>
                     <li><a href="list_category.php">List Category</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="book-open"></i><span >Pages</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_page.php">Add Pages</a></li>
                     <li><a href="list_page.php">List Pages</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="help-circle"></i><span >FAQ</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_faq.php">Add FAQ</a></li>
                     <li><a href="list_faq.php">List FAQ</a></li>
                  </ul>
               </li>
               <li class="sidebar-list"><a class="sidebar-link sidebar-title link-nav" href="payment_list.php">
                  <i data-feather="database"></i><span>Payment List</span></a>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6>Sponsores & Payout </h6>
                  </div>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="speaker"></i><span >Organizer</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_sponsore.php">Add Organizer</a></li>
                     <li><a href="list_sponsore.php">List Organizer</a></li>
                  </ul>
               </li>
               <li class="sidebar-list"><a class="sidebar-link sidebar-title link-nav" href="list_payout.php">
                  <i data-feather="file-plus"></i><span>Payout List</span></a>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6>Facility & Restrication </h6>
                  </div>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="globe"></i><span >Event Facility</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_facility.php">Add Facility</a></li>
                     <li><a href="list_facility.php">List Facility</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="shield-off"></i><span >Event Restrication</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_restriction.php">Add Restrication</a></li>
                     <li><a href="list_restriction.php">List Restrication</a></li>
                  </ul>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6>User </h6>
                  </div>
               </li>
               <li class="sidebar-list"><a class="sidebar-link sidebar-title link-nav" href="list_user.php">
                  <i data-feather="users"></i><span>User List</span></a>
               </li>
            </ul>
         </div>
         <div class="right-arrow" id="right-arrow"><i data-feather="arrow-right"></i></div>
      </nav>
   </div>
</div>
<?php } else { ?>
<div class="sidebar-wrapper" sidebar-layout="stroke-svg">
   <div>
      <div class="logo-wrapper">
         <a href="dashboard.php"><img class="img-fluid for-light" src="<?php echo $set[
            "weblogo"
            ]; ?>" alt=""><img class="img-fluid for-dark" src="<?php echo $set[
            "weblogo"
            ]; ?>" alt=""></a>
         <div class="back-btn"><i class="fa fa-angle-left"></i></div>
         <div class="toggle-sidebar"><i class="status_toggle middle sidebar-toggle" data-feather="grid"> </i></div>
      </div>
      <div class="logo-icon-wrapper"><a href="dashboard.php"><img class="img-fluid" src="<?php echo $set[
         "weblogo"
         ]; ?>" width="50px" alt=""></a></div>
      <nav class="sidebar-main" aria-label="">
         <div class="left-arrow" id="left-arrow"><i data-feather="arrow-left"></i></div>
         <div id="sidebar-menu">
            <ul class="sidebar-links" id="simple-bar">
               <li class="back-btn">
                  <a href="dashboard.php"><img class="img-fluid" src="<?php echo $set[
                     "weblogo"
                     ]; ?>" alt=""></a>
                  <div class="mobile-back text-end">
                    <span>Back</span><i class="fa fa-angle-right ps-2" aria-hidden="true"></i></div>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6 >General</h6>
                  </div>
               </li>
               <li class="sidebar-list"><a class="sidebar-link sidebar-title link-nav" href="dashboard.php">
                  <i data-feather="home"></i><span>DashBoard</span></a>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6 >Event</h6>
                  </div>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="cast"></i><span >Event</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_event.php">Add Event</a></li>
                     <li><a href="list_event.php">List Event</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="cast"></i><span >Event Type & Price</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_etype.php">Add Price</a></li>
                     <li><a href="list_etype.php">List Price</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="image"></i><span >Cover Images</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_cover.php">Add Cover</a></li>
                     <li><a href="list_cover.php">List Cover</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="image"></i><span >Event Gallery</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_gallery.php">Add Gallery</a></li>
                     <li><a href="list_gallery.php">List Gallery</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="users"></i><span >Event Artist</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_artist.php">Add Artist</a></li>
                     <li><a href="list_artist.php">List Artist</a></li>
                  </ul>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="gift"></i><span >Event Coupon</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_coupon.php">Add Coupon</a></li>
                     <li><a href="list_coupon.php">List Coupon</a></li>
                  </ul>
               </li>
               <li class="sidebar-main-title">
                  <div>
                     <h6>Payout </h6>
                  </div>
               </li>
               <li class="sidebar-list">
                  <a class="sidebar-link sidebar-title" href="javascript:void(0);">
                  <i data-feather="file-plus"></i><span >Payout</span></a>
                  <ul class="sidebar-submenu">
                     <li><a href="add_payout.php">Add Payout</a></li>
                     <li><a href="list_epayout.php">List Payout</a></li>
                  </ul>
               </li>
            </ul>
         </div>
         <div class="right-arrow" id="right-arrow"><i data-feather="arrow-right"></i></div>
      </nav>
   </div>
</div>
<?php }
   ?>
