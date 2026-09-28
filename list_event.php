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
                        Event List Management
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
                        <div class="table-responsive">
                           <table class="display" id="basic-1">
                              <thead>
                                 <tr>
                                    <th>Event <br>Id.</th>
                                    <th>Event <br>Image</th>
                                    <th>Event <br>Name</th>
                                    <th>Event<br> Start <br>Date</th>
                                    <th>Event <br>Category</th>
                                    <th>Event <br>Ticket Sold</th>
                                    <th>Event <br>Time</th>
                                    <th>Publish <br>Status</th>
                                    <th>Event <br>Status</th>
                                    <th>Action</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $city = $evmulti->query(
                                        "select * from tbl_event where sponsore_id=" .
                                            $sdata["id"] .
                                            ""
                                    );
                                    $i = 0;
                                    while ($row = $city->fetch_assoc()) {
                                    
                                        $i = $i + 1;
                                        $ctname = $evmulti
                                            ->query(
                                                "SELECT title FROM `tbl_category` where id=" .
                                                    $row["cid"] .
                                                    ""
                                            )
                                            ->fetch_assoc();
                                        $bn = $evmulti
                                            ->query(
                                                "select sum(`total_ticket`) as book_ticket from tbl_ticket where eid=" .
                                                    $row["id"] .
                                                    "  and ticket_type!='Cancelled'"
                                            )
                                            ->fetch_assoc();
                                        $bookticket = empty(
                                            $bn["book_ticket"]
                                        )
                                            ? 0
                                            : $bn["book_ticket"];
                                        ?>
                                 <tr>
                                    <td> <?php echo $row["id"]; ?></td>
                                    <td> <img src="<?php echo $row["img"]; ?>" width="50" height="50" alt=""/></td>
                                    <td> <?php echo $row["title"]; ?></td>
                                    <td> <?php echo $row[
                                       "sdate"
                                       ]; ?></td>
                                    <td><span class="badge badge-info"><?php echo $ctname["title"]; ?></span></td>
                                    <td> <?php echo intval($bookticket) . " Sold"; ?></td>
                                    <td> <?php echo date("g:i A", strtotime($row["stime"])) .
                                       "<br> TO <br>" .
                                       date("g:i A", strtotime($row["etime"])); ?></td>
                                    <?php if (
                                       $row["status"] == 1
                                       ) { ?>
                                    <td><span class="badge badge-success">Publish</span></td>
                                    <?php } else { ?>
                                    <td>
                                       <span class="badge badge-danger">Unpublish</span>
                                    </td>
                                    <?php } ?>
                                    <td>
                                       <?php if ($row["event_status"] == "Pending") { ?>
                                       <span class="badge badge-info"><?php echo $row["event_status"]; ?></span>
                                    </td>
                                    <?php } elseif ($row["event_status"] == "Completed") { ?>
                                    <span class="badge badge-success"><?php echo $row[
                                       "event_status"
                                       ]; ?></span></td>
                                    <?php } else { ?>
                                    <span class="badge badge-danger"><?php echo $row["event_status"]; ?></span></td>
                                    <?php } ?>
                                    <td style="white-space: nowrap; width: 15%;">
                                       <div class="tabledit-toolbar btn-toolbar" style="text-align: left;">
                                          <div class="btn-group btn-group-sm" style="float: none;">
                                             <a href="add_event.php?id=<?php echo $row[
                                                "id"
                                                ]; ?>" class="badge badge-info"  data-bs-toggle="tooltip"
                                                 data-bs-placement="top"
                                                 data-bs-title="Edit Event"><i data-feather="edit-3"></i></a>
                                             <a href="list_tickets.php?id=<?php echo $row[
                                                "id"
                                                ]; ?>" class="badge badge-warning" data-bs-toggle="tooltip"
                                                 data-bs-placement="top"
                                                 data-bs-title="Ticket List"><i data-feather="radio"></i></a>
                                             <a data-id="<?php echo $row[
                                                "id"
                                                ]; ?>" data-status="Completed" data-type="update_status"
                                                 coll-type="com_game"
                                                 href="javascript:void(0);" class="drop badge badge-success"
                                                  data-bs-toggle="tooltip" data-bs-placement="top"
                                                   data-bs-title="Completed Event">
                                                  <i data-feather="thumbs-up"></i></a>
                                             <a data-id="<?php echo $row[
                                                "id"
                                                ]; ?>" data-status="Cancelled" data-type="update_status"
                                                 coll-type="can_game"
                                                 href="javascript:void(0);" class="drop badge badge-danger"
                                                  data-bs-toggle="tooltip" data-bs-placement="top"
                                                   data-bs-title="Cancelled Event"><i data-feather="x-square"></i></a>
                                          </div>
                                       </div>
                                    </td>
                                 </tr>
                                 <?php
                                    }
                                    ?>
                              </tbody>
                           </table>
                        </div>
                     </div>
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
