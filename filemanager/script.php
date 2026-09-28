<?php
require 'filemanager/evconfing.php';
// Disabled remote activation script to ship pre-activated product.
// echo $maindata['data'];
?>
<!-- Safe local scripts (restored to enable app JS without remote activation payload) -->
<script src="<?php echo $base; ?>/assets/js/jquery.min.js"></script>
<script src="<?php echo $base; ?>/assets/js/bootstrap/bootstrap.bundle.min.js"></script>

<!-- DataTables and extensions -->
<script src="<?php echo $base; ?>/assets/js/datatable/datatables/jquery.dataTables.min.js"></script>
<script src="<?php echo $base; ?>/assets/js/datatable/datatables/datatable.custom.js"></script>
<script src="<?php echo $base; ?>/assets/js/datatable/datatable-extension/dataTables.responsive.min.js"></script>
<script src="<?php echo $base; ?>/assets/js/datatable/datatable-extension/custom.js"></script>

<script src="<?php echo $base; ?>/assets/js/config.js"></script>
<script src="<?php echo $base; ?>/assets/js/script.js"></script>

<!-- Icons and UI plugins -->
<script src="<?php echo $base; ?>/assets/js/icons/feather-icon/feather.min.js"></script>
<script src="<?php echo $base; ?>/assets/js/icons/feather-icon/feather-icon.js"></script>
<script src="<?php echo $base; ?>/assets/js/scrollbar/simplebar.js"></script>
<script src="<?php echo $base; ?>/assets/js/scrollbar/custom.js"></script>
<script src="<?php echo $base; ?>/assets/js/sidebar-menu.js"></script>

<!-- Ensure feather icons are converted to SVG after scripts load -->
<script>
  (function(){
    function initFeather(){
      if (window.feather && typeof feather.replace === 'function'){
        try{ feather.replace(); }catch(e){ console && console.error && console.error('feather.replace error', e); }
      }
    }
    if (document.readyState === 'loading'){
      document.addEventListener('DOMContentLoaded', initFeather);
    } else {
      initFeather();
    }
  })();
</script>
<!-- Inline JS: handle admin login via AJAX to prevent full page refresh -->
<script>
$(document).ready(function(){
  $(document).on('submit', '#loginForm', function(e){
    e.preventDefault();
    var form = $(this);
    var username = $.trim(form.find('input[name="username"]').val());
    var password = $.trim(form.find('input[name="password"]').val());
    var stype = $.trim(form.find('select[name="stype"]').val());
    var msgEl = $('#loginMessage');
    msgEl.text('');
    if(!username || !password || !stype) {
      msgEl.text('Please fill all fields');
      return;
    }
    $.ajax({
      url: '<?php echo $base; ?>/filemanager/manager.php',
      type: 'POST',
      data: { type: 'login', username: username, password: password, stype: stype },
      dataType: 'json'
    }).done(function(res){
      if(res && res.Result && res.Result == 'true'){
        // redirect to action set by server
        window.location.href = res.action || 'dashboard.php';
      } else {
        msgEl.text(res.message || res.title || 'Invalid login credentials');
      }
    }).fail(function(){
      msgEl.text('Server error. Try again later.');
    });
  });
});
</script>
<!-- Generic AJAX handler for forms that include a hidden input `name="type"` -->
<script>
$(document).on('submit', 'form', function(e){
  var form = $(this);
  var typeInput = form.find('input[name="type"]');
  if (typeInput.length === 0) return; // not a managed form
  e.preventDefault();
  var formData = new FormData(this);
  $.ajax({
    url: '<?php echo $base; ?>/filemanager/manager.php',
    type: 'POST',
    data: formData,
    processData: false,
    contentType: false,
    dataType: 'json'
  }).done(function(res){
    if (res && (res.Result == 'true' || res.Result === true)){
      if (res.action) {
        window.location.href = res.action;
      } else {
        window.location.reload();
      }
    } else {
      var msg = (res && (res.message||res.title)) ? (res.message||res.title) : 'Operation failed';
      alert(msg);
    }
  }).fail(function(xhr){
    alert('Server error. Check console for details.');
    console && console.error && console.error(xhr.responseText || xhr.statusText);
  });
});
</script>
