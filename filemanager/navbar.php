<div class="page-header">
        <div class="header-wrapper row m-0">
          
          <div class="header-logo-wrapper col-auto p-0">
            <div class="logo-wrapper"><a href="dashboard.php"><img class="img-fluid"
             src="<?php echo $set['weblogo'];?>" alt=""></a></div>
            <div class="toggle-sidebar">
              <i class="status_toggle middle sidebar-toggle" data-feather="align-center"></i></div>
          </div>
          
          <div class="nav-right col-xxl-7 col-xl-6 col-md-7 col-8 pull-right right-header p-0 ms-auto">
            <ul class="nav-menus">
              
              
              <?php
 if (isset($_SESSION['stype'])) {
if ($_SESSION['stype'] == 'sowner') {
?>
<li class="profile-nav onhover-dropdown pe-0 py-0">
                <div class="media profile-media">
                  <img class="b-r-10" src="<?php echo $sdata['img'];?>" width="40" height="40" alt="">
                  <div class="media-body"><span><?php echo $sdata['title'];?></span>
                    <p class="mb-0 font-roboto">Organizer <i data-feather="chevron-down"></i></p>
                  </div>
                </div>
                <ul class="profile-dropdown onhover-show-div">
<li><a href="oprofile.php"><i data-feather="user"></i><span>Profile </span></a></li>
                  <li><a href="logout.php"><i data-feather="log-out"> </i><span>Log out</span></a></li>
                </ul>
              </li>
<?php
} else {
?>
              
              <li class="profile-nav onhover-dropdown pe-0 py-0">
                <div class="media profile-media"><img class="b-r-10" src="images/5.png" width="40" height="40" alt="">
                  <div class="media-body"><span>Main Admin</span>
                    <p class="mb-0 font-roboto">Admin <i data-feather="chevron-down"></i></p>
                  </div>
                </div>
                <ul class="profile-dropdown onhover-show-div">
                  <li><a href="profile.php"><i data-feather="user"></i><span>Profile </span></a></li>
                  <li><a href="setting.php"><i data-feather="settings"></i><span>Settings</span></a></li>
                  <li><a href="logout.php"><i data-feather="log-out"> </i><span>Log out</span></a></li>
                </ul>
              </li>
<?php } }?>
            </ul>
          </div>
          <script class="result-template" type="text/x-handlebars-template">
            <div class="ProfileCard u-cf">
            <div class="ProfileCard-avatar"><svg xmlns="http://www.w3.org/2000/svg"
             width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
              stroke-linecap="round" stroke-linejoin="round" class="feather feather-airplay m-0">
              <path d="M5 17H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-1">

              </path><polygon points="12 15 17 21 7 21 12 15"></polygon></svg></div>
            <div class="ProfileCard-details">
            <div class="ProfileCard-realName">{{name}}</div>
            </div>
            </div>
          </script>
          <script class="empty-template" type="text/x-handlebars-template">
            <div class="EmptyMessage">Your search turned up 0 results. This most
               likely means the backend is down, yikes!</div></script>
        </div>
      </div>
