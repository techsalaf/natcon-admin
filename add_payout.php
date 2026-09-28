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
                        Payout Management
                     </h3>
                     <br>
                     <ul class="blink_me bullet">
                        <li >The sale amount generated after completing an event,
and not from pending or cancelled events, generates sales.</li>
                        <li>You cannot ask for a payout above your specified withdrawal payout limit.</li>
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
                  <div class="card">
                     <div class="card-body">
                        <div class="row">
                           <div class="col-md-4">
                              <div class="card small-widget">
                                 <div class="card-body warning">
                                    <span class="f-light">Wallet Balance</span>
                                    <div class="d-flex align-items-end gap-1">
                                       <h4><?php
                                          $total_earn = $evmulti
                                              ->query(
           "select sum((subtotal-cou_amt) - ((subtotal-cou_amt) * commission/100))
as total_amt
from tbl_ticket where sponsore_id=" .
                                                      $sdata["id"] .
                                                      " and ticket_type ='Completed'"
                                              )
                                              ->fetch_assoc();
                                          $earn = empty($total_earn["total_amt"])
                                              ? 0
                                              : number_format(
                                                  (float) $total_earn["total_amt"],
                                                  2,
                                                  ".",
                                                  ""
                                              );
                                          
                                          $total_payout = $evmulti
                                              ->query(
                                                  "select sum(amt) as total_payout from payout_setting
 where owner_id=" .
                                                      $sdata["id"] .
                                                      ""
                                              )
                                              ->fetch_assoc();
                                          $payout = empty($total_payout["total_payout"])
                                              ? "0"
                                              : number_format(
                                                  (float) $total_payout["total_payout"],
                                                  2,
                                                  ".",
                                                  ""
                                              );
                                          
                                          echo number_format(
                                              (float) $earn - $payout,
                                              2,
                                              ".",
                                              ""
                                          ) . $set["currency"];
                                          ?></h4>
                                    </div>
                                    <div class="bg-gradient">
                                       <i data-feather="credit-card" class="svg-fill"></i>
                                    </div>
                                 </div>
                              </div>
                           </div>
                           <div class="col-md-4">
                           </div>
                           <div class="col-md-4">
                              <div class="card small-widget">
                                 <div class="card-body warning">
                                    <span class="f-light">Wallet Min Balance For Withdraw</span>
                                    <div class="d-flex align-items-end gap-1">
                                       <h4><?php echo $set["pstore"] .
                                          " " .
                                          $set["currency"]; ?></h4>
                                    </div>
                                    <div class="bg-gradient">
                                       <i data-feather="target" class="svg-fill"></i>
                                    </div>
                                 </div>
                              </div>
                           </div>
                        </div>
                        <br>
                        <form method="post" enctype="multipart/form-data">
                           <div class="form-group mb-3">
                              <label>Amount</label>
                              <input type="number" min="1" step="0.01"  class="form-control"
placeholder="Enter Amount" name="amt" required="">
                              <input type="hidden" name="type" value="add_payout"/>
                           </div>
                           <div class="form-group mb-3">
                              <label>Select Payout Type</label>
                              <select name="r_type" id="r_type" class="form-control" required>
                                 <option value="" >Select Option</option>
                                 <option value="UPI" >UPI</option>
                                 <option value="BANK Transfer"  >BANK Transfer</option>
                                 <option value="Paypal"  >Paypal</option>
                              </select>
                           </div>
                           <div class="form-group mb-3 div1">
                              <label>Upi Address</label>
                              <input type="text" class="form-control"
 id="upi_id" name="upi_id" placeholder="Enter Upi Address">
                           </div>
                           <div class="form-group mb-3 div2">
                              <label>Paypal Id</label>
                              <input type="text"   class="form-control"
 id="paypal_id" name="paypal_id" placeholder="Enter Paypal Id">
                           </div>
                           <div class="form-group mb-3 div3">
                              <label>Account Number</label>
                              <input type="text"   class="form-control"
id="acc_number" name="acc_number" placeholder="Enter Account Number">
                           </div>
                           <div class="form-group mb-3 div4">
                              <label>Bank Name</label>
                              <input type="text"   class="form-control"
id="bank_name" name="bank_name" placeholder="Enter Bank Name">
                           </div>
                           <div class="form-group mb-3 div5">
                              <label>Account Holder Name</label>
                              <input type="text"   class="form-control"
 id="acc_name" name="acc_name" placeholder="Enter Account Holder Name">
                           </div>
                           <div class="form-group mb-3 div6">
                              <label>IFSC Code</label>
                              <input type="text"   class="form-control"
 id="ifsc_code" name="ifsc_code" placeholder="Enter IFSC Code">
                           </div>
                           <div class="form-group mb-3">
                              <button type="submit" class="btn btn-primary mb-2">Request Payout</button>
                           </div>
                     </div>
                     </form>
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
<script>
   $("#upi_id").hide();
   $("#paypal_id").hide();
   $("#acc_number").hide();
   $("#bank_name").hide();
   $("#acc_name").hide();
   $("#ifsc_code").hide();
   $(".div1").hide();
   $(".div2").hide();
   $(".div3").hide();
   $(".div4").hide();
   $(".div5").hide();
   $(".div6").hide();
   
   $(document).on('change','#r_type',function(e) {
   var val = $(this).val();
   if(val == '') {
   $("#upi_id").hide();
   $("#paypal_id").hide();
   $("#acc_number").hide();
   $("#bank_name").hide();
   $("#acc_name").hide();
   $("#ifsc_code").hide();
   $(".div1").hide();
   $(".div2").hide();
   $(".div3").hide();
   $(".div4").hide();
   $(".div5").hide();
   $(".div6").hide();
   } else if(val == 'UPI') {
   $("#upi_id").show();
   $("#paypal_id").hide();
   $("#acc_number").hide();
   $("#bank_name").hide();
   $("#acc_name").hide();
   $("#ifsc_code").hide();
   $(".div1").show();
   $(".div2").hide();
   $(".div3").hide();
   $(".div4").hide();
   $(".div5").hide();
   $(".div6").hide();
   
   $('#upi_id').attr('required', 'required');
   $("#paypal_id").removeAttr("required");
   $("#acc_number").removeAttr("required");
   $("#bank_name").removeAttr("required");
   $("#acc_name").removeAttr("required");
   $("#ifsc_code").removeAttr("required");
   } else if(val == 'Paypal') {
   $("#upi_id").hide();
   $("#paypal_id").show();
   $("#acc_number").hide();
   $("#bank_name").hide();
   $("#acc_name").hide();
   $("#ifsc_code").hide();
   $(".div1").hide();
   $(".div2").show();
   $(".div3").hide();
   $(".div4").hide();
   $(".div5").hide();
   $(".div6").hide();
   
   $('#paypal_id').attr('required', 'required');
   $("#upi_id").removeAttr("required");
   $("#acc_number").removeAttr("required");
   $("#bank_name").removeAttr("required");
   $("#acc_name").removeAttr("required");
   $("#ifsc_code").removeAttr("required");
   } else  {
   $("#upi_id").hide();
   $("#paypal_id").hide();
   $("#acc_number").show();
   $("#bank_name").show();
   $("#acc_name").show();
   $("#ifsc_code").show();
   $(".div1").hide();
   $(".div2").hide();
   $(".div3").show();
   $(".div4").show();
   $(".div5").show();
   $(".div6").show();
   $('#acc_number').attr('required', 'required');
   $('#bank_name').attr('required', 'required');
   $('#acc_name').attr('required', 'required');
   $('#ifsc_code').attr('required', 'required');
   $("#upi_id").removeAttr("required");
   $("#paypal_id").removeAttr("required");
   }
   });
</script>
</body>
</html>
