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
                  <div class="col-8">
                     <h3>
                        Event Management
                     </h3>
                     <br>
                     <p class="blink_me">
                     <ul class="blink_me bullet">
                        <li >If you select a marker on the map and then drag it
                           to another location, you will obtain the address and latitude-longitude coordinates.
                           Alternatively, if you search for an address directly, you will also obtain
                           its corresponding latitude-longitude coordinates and address.
                        </li>
                        <li>The inclusion of event tags and video URL is optional.</li>
                     </ul>
                     </p>
                  </div>
                  <div class="col-4">
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
                              "select * from tbl_event where id=" .
                                  $_GET["id"] .
                                  " and sponsore_id=" .
                                  $sdata["id"] .
                                  ""
                          )
                          ->fetch_assoc();
                      $count = $evmulti->query(
                          "select * from tbl_event where id=" .
                              $_GET["id"] .
                              " and sponsore_id=" .
                              $sdata["id"] .
                              ""
                      )->num_rows;
                      if ($count != 0) { ?>
                  <div class="card">
                     <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                           <div class="row">
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Name</label>
                                    <input type="text" class="form-control" name="title" value="<?php echo $data[
                                        "title"
                                    ]; ?>" placeholder="Enter Event Name"  required="">
                                    <input type="hidden" name="type" value="edit_event"/>
                                    <input type="hidden" name="id" value="<?php echo $_GET[
                                        "id"
                                    ]; ?>"/>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Image</label>
                                    <div class="input-group">
                                       <input type="file" name="cat_img">
                                       <img src="<?php echo $data[
                                           "img"
                                       ]; ?>" width="100" height="100" alt=""/>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Cover Image</label>
                                    <div class="input-group">
                                       <input type="file" name="cover_img">
                                       <img src="<?php echo $data[
                                           "cover_img"
                                       ]; ?>" width="100" height="100" alt=""/>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Start Date</label>
                                    <input type="date" name="sdate" class="form-control" value="<?php echo $data[
                                        "sdate"
                                    ]; ?>" placeholder="Select Date" required>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Start Time</label>
                                    <div class="input-group">
                                       <input type="time" name="stime" class="form-control" value="<?php echo $data[
                                           "stime"
                                       ]; ?>" required>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event End Time</label>
                                    <div class="input-group">
                                       <input type="time" name="etime" class="form-control" value="<?php echo $data[
                                           "etime"
                                       ]; ?>" required>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Tags</label>
                                    <div class="input-group">
                                       <input type="text" name="tags" class="form-control"
                                          data-role="tagsinput" value="<?php echo $data[
                                              "tags"
                                          ]; ?>">
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Video Urls</label>
                                    <div class="input-group">
                                       <input type="text" name="vurls" class="form-control"
                                          data-role="tagsinput" value="<?php echo $data[
                                              "vurls"
                                          ]; ?>">
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-12 col-lg-12 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <input id="searchInput" class="input-controls"
                                       type="text" placeholder="Enter a location">
                                    <div class="map" id="map"></div>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Latitude</label>
                                    <input type="text" class="form-control " name="latitude" value="<?php echo $data[
                                        "latitude"
                                    ]; ?>" placeholder="Enter Latitude"  required="" readonly>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Longtitude</label>
                                    <input type="text" class="form-control " name="longtitude" value="<?php echo $data[
                                        "longtitude"
                                    ]; ?>" placeholder="Enter Longtitude"  required="" readonly>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Place Name</label>
                                    <input type="text" class="form-control " name="pname" value="<?php echo $data[
                                        "place_name"
                                    ]; ?>" placeholder="Enter Place Name"required="">
                                 </div>
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Full Address</label>
                                    <textarea class="form-control" rows="10" name="address"
                                       style="resize:none;" required><?php echo $data[
                                           "address"
                                       ]; ?></textarea>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Status</label>
                                    <select name="status" name="status" class="form-control " required>
                                       <option value="">Select Status</option>
                                       <option value="1" <?php if (
                                           $data["status"] == 1
                                       ) {
                                           echo "selected";
                                       } ?>>Publish</option>
                                       <option value="0" <?php if (
                                           $data["status"] == 0
                                       ) {
                                           echo "selected";
                                       } ?>>Unpublish</option>
                                    </select>
                                 </div>
                                 <div class="form-group ">
                                    <label>Event Category</label>
                                    <select name="cid" name="status" class="form-control select2-single" required>
                                       <option value="">Select Category</option>
                                       <?php
                                       $cat = $evmulti->query(
                                           "select * from tbl_category"
                                       );
                                       while ($row = $cat->fetch_assoc()) { ?>
                                       <option value="<?php echo $row[
                                           "id"
                                       ]; ?>" <?php if (
    $data["cid"] == $row["id"]
) {
    echo "selected";
} ?>><?php echo $row["title"]; ?></option>
                                       <?php }
                                       ?>
                                    </select>
                                 </div>
                                 <div class="form-group">
                                    <label>Event Facility</label>
                                    <select name="facility_id[]"  class="form-control select2-multi-select"  multiple>
                                       <?php
                                       $cat = $evmulti->query(
                                           "select * from tbl_facility"
                                       );
                                       $people = explode(
                                           ",",
                                           $data["facility_id"]
                                       );
                                       while ($row = $cat->fetch_assoc()) { ?>
                                       <option value="<?php echo $row[
                                           "id"
                                       ]; ?>" <?php if (
    in_array($row["id"], $people)
) {
    echo "selected";
} ?>><?php echo $row["title"]; ?></option>
                                       <?php }
                                       ?>
                                    </select>
                                 </div>
                                 <div class="form-group">
                                    <label>Event Restriction</label>
                                    <select name="restict_id[]"  class="form-control select2-multi-select"  multiple>
                                       <?php
                                       $cat = $evmulti->query(
                                           "select * from tbl_restriction"
                                       );
                                       $people = explode(
                                           ",",
                                           $data["restict_id"]
                                       );
                                       while ($row = $cat->fetch_assoc()) { ?>
                                       <option value="<?php echo $row[
                                           "id"
                                       ]; ?>" <?php if (
    in_array($row["id"], $people)
) {
    echo "selected";
} ?>><?php echo $row["title"]; ?></option>
                                       <?php }
                                       ?>
                                    </select>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Description</label>
                                    <textarea class="form-control" rows="5" id="cdesc" name="cdesc"
                                       style="resize: none;" required><?php echo $data[
                                           "description"
                                       ]; ?></textarea>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Disclaimer</label>
                                    <textarea class="form-control" rows="5" id="disclaimer"
                                       name="disclaimer" style="resize: none;" required><?php echo $data[
                                           "disclaimer"
                                       ]; ?></textarea>
                                 </div>
                              </div>
                              <div class="form-group">
                                 <button type="submit" class="btn btn-rounded btn-primary">
                                 <span class="btn-icon-start text-primary"><i class="flaticon-381-speaker"></i>
                                 </span>Edit Event</button>
                              </div>
                           </div>
                     </div>
                     </form>
                  </div>
                  <?php } else { ?>
                  <div class="card">
                     <div class="card-body text-center">
                        <h6>
                           Check Own Event Or Add New Event Of Below Click Button.
                        </h6>
                        <br>
                        <a href="add_event.php" class="btn btn-primary">Add Event</a>
                     </div>
                  </div>
                  <?php }
                  } else {
                       ?>
                  <div class="card">
                     <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                           <div class="row">
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Name</label>
                                    <input type="text" class="form-control" name="title"
                                       placeholder="Enter Event Name"  required="">
                                    <input type="hidden" name="type" value="add_events"/>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Image</label>
                                    <div class="input-group">
                                       <input type="file" name="cat_img" required>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Cover Image</label>
                                    <div class="input-group">
                                       <input type="file" name="cover_img" required>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Start Date</label>
                                    <input type="date" name="sdate" class="form-control"
                                       placeholder="Select Date" required>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Start Time</label>
                                    <div class="input-group">
                                       <input type="time" name="stime" class="form-control" required>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-4 col-lg-4 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event End Time</label>
                                    <div class="input-group">
                                       <input type="time" name="etime" class="form-control" required>
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Tags</label>
                                    <div class="input-group">
                                       <input type="text" name="tags" class="form-control" data-role="tagsinput" >
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Video Urls</label>
                                    <div class="input-group">
                                       <input type="text" name="vurls" class="form-control" data-role="tagsinput" >
                                    </div>
                                 </div>
                              </div>
                              <div class="col-md-12 col-lg-12 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <input id="searchInput" class="input-controls"
                                       type="text" placeholder="Enter a location">
                                    <div class="map" id="map"></div>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Latitude</label>
                                    <input type="text" class="form-control" id="lat"
                                       name="latitude" placeholder="Enter Latitude"  required="" readonly>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Longtitude</label>
                                    <input type="text" class="form-control "
                                       id="lng" name="longtitude" placeholder="Enter Longtitude"  required="" readonly>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Place Name</label>
                                    <input type="text" class="form-control "
                                       name="pname" placeholder="Enter Place Name"required="">
                                 </div>
                                 <div class="form-group mb-3">
                                    <label class="form-label">Event Full Address</label>
                                    <textarea class="form-control" rows="10" name="address"
                                       id="location" style="resize:none;" required></textarea>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Status</label>
                                    <select name="status" name="status" class="form-control " required>
                                       <option value="">Select Status</option>
                                       <option value="1">Publish</option>
                                       <option value="0">UnPublish</option>
                                    </select>
                                 </div>
                                 <div class="form-group">
                                    <label>Event Category</label>
                                    <select name="cid" name="status" class="form-control select2-single" required>
                                       <option value="" disabled selected>Select Category</option>
                                       <?php
                                       $cat = $evmulti->query(
                                           "select * from tbl_category"
                                       );
                                       while ($row = $cat->fetch_assoc()) { ?>
                                       <option value="<?php echo $row[
                                           "id"
                                       ]; ?>"><?php echo $row[
    "title"
]; ?></option>
                                       <?php }
                                       ?>
                                    </select>
                                 </div>
                                 <div class="form-group">
                                    <label>Event Facility</label>
                                    <select name="facility_id[]"  class="form-control select2-multi-select"  multiple>
                                       <?php
                                       $cat = $evmulti->query(
                                           "select * from tbl_facility"
                                       );
                                       while ($row = $cat->fetch_assoc()) { ?>
                                       <option value="<?php echo $row[
                                           "id"
                                       ]; ?>"><?php echo $row[
    "title"
]; ?></option>
                                       <?php }
                                       ?>
                                    </select>
                                 </div>
                                 <div class="form-group">
                                    <label>Event Restriction</label>
                                    <select name="restict_id[]"  class="form-control select2-multi-select"  multiple>
                                       <?php
                                       $cat = $evmulti->query(
                                           "select * from tbl_restriction"
                                       );
                                       while ($row = $cat->fetch_assoc()) { ?>
                                       <option value="<?php echo $row[
                                           "id"
                                       ]; ?>"><?php echo $row[
    "title"
]; ?></option>
                                       <?php }
                                       ?>
                                    </select>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Description</label>
                                    <textarea class="form-control" rows="5" id="cdesc" name="cdesc"
                                       style="resize: none;" required></textarea>
                                 </div>
                              </div>
                              <div class="col-md-6 col-lg-6 col-xs-12 col-sm-12">
                                 <div class="form-group mb-3">
                                    <label>Event Disclaimer</label>
                                    <textarea class="form-control" rows="5" id="disclaimer" name="disclaimer"
                                       style="resize: none;" required></textarea>
                                 </div>
                              </div>
                              <div class="form-group">
                                 <button type="submit" class="btn btn-rounded btn-primary">
                                 <span class="btn-icon-start text-primary"><i class="flaticon-381-speaker"></i>
                                 </span>Add Event</button>
                              </div>
                           </div>
                     </div>
                     </form>
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
<script type="text/javascript"
   src="https://maps.googleapis.com/maps/api/js?sensor=false&libraries=places&key=AIzaSyB8-
   ypkZ-83OMzbMUGrJWa2v-XBIqQWHdo">
</script>
<script>
   /* script */
   function initialize() {
<?php if (isset($_GET["id"])) { ?>
var latlng = new google.maps.LatLng(<?php echo $data[
         "latitude"
     ]; ?>,<?php echo $data["longtitude"]; ?>);
<?php } else { ?>
      var latlng = new google.maps.LatLng(28.5355161,77.39102649999995);
<?php } ?>
       var map = new google.maps.Map(document.getElementById('map'), {
         center: latlng,
         zoom: 13
       });
       var marker = new google.maps.Marker({
         map: map,
         position: latlng,
         draggable: true,
         anchorPoint: new google.maps.Point(0, -29)
      });
       var input = document.getElementById('searchInput');
       map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
       var geocoder = new google.maps.Geocoder();
       var autocomplete = new google.maps.places.Autocomplete(input);
       autocomplete.bindTo('bounds', map);
       var infowindow = new google.maps.InfoWindow();
       autocomplete.addListener('place_changed', function() {
           infowindow.close();
           marker.setVisible(false);
           var place = autocomplete.getPlace();
           if (!place.geometry) {
               window.alert("Autocomplete's returned place contains no geometry");
               return;
           }
           // If the place has a geometry, then present it on a map.
           if (place.geometry.viewport) {
               map.fitBounds(place.geometry.viewport);
           } else {
               map.setCenter(place.geometry.location);
               map.setZoom(17);
           }
           marker.setPosition(place.geometry.location);
           marker.setVisible(true);
           bindDataToForm(place.formatted_address,place.geometry.location.lat(),place.geometry.location.lng());
           infowindow.setContent(place.formatted_address);
           infowindow.open(map, marker);
       });
       
       google.maps.event.addListener(marker, 'dragend', function() {
           geocoder.geocode({'latLng': marker.getPosition()}, function(results, status) {
           if (status == google.maps.GeocoderStatus.OK) {
             if (results[0]) {
   
                 bindDataToForm(results[0].formatted_address,marker.getPosition().lat(),marker.getPosition().lng());
                 infowindow.setContent(results[0].formatted_address);
                 infowindow.open(map, marker);
             }
           }
           });
       });
   }
   function bindDataToForm(address,lat,lng){
      document.getElementById('location').value = address;
      document.getElementById('lat').value = lat;
      document.getElementById('lng').value = lng;
   }
   google.maps.event.addDomListener(window, 'load', initialize);
</script>
<style type="text/css">
   #map
   {
   width: 100%; height: 300px;
   }
   .input-controls {
   margin-top: 10px;
   border: 1px solid transparent;
   border-radius: 2px 0 0 2px;
   box-sizing: border-box;
   -moz-box-sizing: border-box;
   height: 32px;
   outline: none;
   box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
   }
   #searchInput {
   background-color: #fff;
   font-family: Roboto;
   font-size: 15px;
   font-weight: 300;
   margin-left: 12px;
   padding: 0 11px 0 13px;
   text-overflow: ellipsis;
   width: 50%;
   }
   #searchInput:focus {
   border-color: #4d90fe;
   }
</style>
<!-- Plugin used-->
</body>
</html>
