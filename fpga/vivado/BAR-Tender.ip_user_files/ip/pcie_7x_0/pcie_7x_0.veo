// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: xilinx.com:ip:pcie_7x:3.3
// IP Revision: 8

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
pcie_7x_0 your_instance_name (
  .pci_exp_txp(pci_exp_txp),                                                                // output wire [0 : 0] pci_exp_txp
  .pci_exp_txn(pci_exp_txn),                                                                // output wire [0 : 0] pci_exp_txn
  .pci_exp_rxp(pci_exp_rxp),                                                                // input wire [0 : 0] pci_exp_rxp
  .pci_exp_rxn(pci_exp_rxn),                                                                // input wire [0 : 0] pci_exp_rxn
  .user_clk_out(user_clk_out),                                                              // output wire user_clk_out
  .user_reset_out(user_reset_out),                                                          // output wire user_reset_out
  .user_lnk_up(user_lnk_up),                                                                // output wire user_lnk_up
  .user_app_rdy(user_app_rdy),                                                              // output wire user_app_rdy
  .tx_buf_av(tx_buf_av),                                                                    // output wire [5 : 0] tx_buf_av
  .tx_cfg_req(tx_cfg_req),                                                                  // output wire tx_cfg_req
  .tx_err_drop(tx_err_drop),                                                                // output wire tx_err_drop
  .s_axis_tx_tready(s_axis_tx_tready),                                                      // output wire s_axis_tx_tready
  .s_axis_tx_tdata(s_axis_tx_tdata),                                                        // input wire [63 : 0] s_axis_tx_tdata
  .s_axis_tx_tkeep(s_axis_tx_tkeep),                                                        // input wire [7 : 0] s_axis_tx_tkeep
  .s_axis_tx_tlast(s_axis_tx_tlast),                                                        // input wire s_axis_tx_tlast
  .s_axis_tx_tvalid(s_axis_tx_tvalid),                                                      // input wire s_axis_tx_tvalid
  .s_axis_tx_tuser(s_axis_tx_tuser),                                                        // input wire [3 : 0] s_axis_tx_tuser
  .tx_cfg_gnt(tx_cfg_gnt),                                                                  // input wire tx_cfg_gnt
  .m_axis_rx_tdata(m_axis_rx_tdata),                                                        // output wire [63 : 0] m_axis_rx_tdata
  .m_axis_rx_tkeep(m_axis_rx_tkeep),                                                        // output wire [7 : 0] m_axis_rx_tkeep
  .m_axis_rx_tlast(m_axis_rx_tlast),                                                        // output wire m_axis_rx_tlast
  .m_axis_rx_tvalid(m_axis_rx_tvalid),                                                      // output wire m_axis_rx_tvalid
  .m_axis_rx_tready(m_axis_rx_tready),                                                      // input wire m_axis_rx_tready
  .m_axis_rx_tuser(m_axis_rx_tuser),                                                        // output wire [21 : 0] m_axis_rx_tuser
  .rx_np_ok(rx_np_ok),                                                                      // input wire rx_np_ok
  .rx_np_req(rx_np_req),                                                                    // input wire rx_np_req
  .cfg_mgmt_do(cfg_mgmt_do),                                                                // output wire [31 : 0] cfg_mgmt_do
  .cfg_mgmt_rd_wr_done(cfg_mgmt_rd_wr_done),                                                // output wire cfg_mgmt_rd_wr_done
  .cfg_status(cfg_status),                                                                  // output wire [15 : 0] cfg_status
  .cfg_command(cfg_command),                                                                // output wire [15 : 0] cfg_command
  .cfg_dstatus(cfg_dstatus),                                                                // output wire [15 : 0] cfg_dstatus
  .cfg_dcommand(cfg_dcommand),                                                              // output wire [15 : 0] cfg_dcommand
  .cfg_lstatus(cfg_lstatus),                                                                // output wire [15 : 0] cfg_lstatus
  .cfg_lcommand(cfg_lcommand),                                                              // output wire [15 : 0] cfg_lcommand
  .cfg_dcommand2(cfg_dcommand2),                                                            // output wire [15 : 0] cfg_dcommand2
  .cfg_pcie_link_state(cfg_pcie_link_state),                                                // output wire [2 : 0] cfg_pcie_link_state
  .cfg_pmcsr_pme_en(cfg_pmcsr_pme_en),                                                      // output wire cfg_pmcsr_pme_en
  .cfg_pmcsr_powerstate(cfg_pmcsr_powerstate),                                              // output wire [1 : 0] cfg_pmcsr_powerstate
  .cfg_pmcsr_pme_status(cfg_pmcsr_pme_status),                                              // output wire cfg_pmcsr_pme_status
  .cfg_received_func_lvl_rst(cfg_received_func_lvl_rst),                                    // output wire cfg_received_func_lvl_rst
  .cfg_mgmt_di(cfg_mgmt_di),                                                                // input wire [31 : 0] cfg_mgmt_di
  .cfg_mgmt_byte_en(cfg_mgmt_byte_en),                                                      // input wire [3 : 0] cfg_mgmt_byte_en
  .cfg_mgmt_dwaddr(cfg_mgmt_dwaddr),                                                        // input wire [9 : 0] cfg_mgmt_dwaddr
  .cfg_mgmt_wr_en(cfg_mgmt_wr_en),                                                          // input wire cfg_mgmt_wr_en
  .cfg_mgmt_rd_en(cfg_mgmt_rd_en),                                                          // input wire cfg_mgmt_rd_en
  .cfg_mgmt_wr_readonly(cfg_mgmt_wr_readonly),                                              // input wire cfg_mgmt_wr_readonly
  .cfg_trn_pending(cfg_trn_pending),                                                        // input wire cfg_trn_pending
  .cfg_pm_halt_aspm_l0s(cfg_pm_halt_aspm_l0s),                                              // input wire cfg_pm_halt_aspm_l0s
  .cfg_pm_halt_aspm_l1(cfg_pm_halt_aspm_l1),                                                // input wire cfg_pm_halt_aspm_l1
  .cfg_pm_force_state_en(cfg_pm_force_state_en),                                            // input wire cfg_pm_force_state_en
  .cfg_pm_force_state(cfg_pm_force_state),                                                  // input wire [1 : 0] cfg_pm_force_state
  .cfg_dsn(cfg_dsn),                                                                        // input wire [63 : 0] cfg_dsn
  .cfg_interrupt(cfg_interrupt),                                                            // input wire cfg_interrupt
  .cfg_interrupt_rdy(cfg_interrupt_rdy),                                                    // output wire cfg_interrupt_rdy
  .cfg_interrupt_assert(cfg_interrupt_assert),                                              // input wire cfg_interrupt_assert
  .cfg_interrupt_di(cfg_interrupt_di),                                                      // input wire [7 : 0] cfg_interrupt_di
  .cfg_interrupt_do(cfg_interrupt_do),                                                      // output wire [7 : 0] cfg_interrupt_do
  .cfg_interrupt_mmenable(cfg_interrupt_mmenable),                                          // output wire [2 : 0] cfg_interrupt_mmenable
  .cfg_interrupt_msienable(cfg_interrupt_msienable),                                        // output wire cfg_interrupt_msienable
  .cfg_interrupt_msixenable(cfg_interrupt_msixenable),                                      // output wire cfg_interrupt_msixenable
  .cfg_interrupt_msixfm(cfg_interrupt_msixfm),                                              // output wire cfg_interrupt_msixfm
  .cfg_interrupt_stat(cfg_interrupt_stat),                                                  // input wire cfg_interrupt_stat
  .cfg_pciecap_interrupt_msgnum(cfg_pciecap_interrupt_msgnum),                              // input wire [4 : 0] cfg_pciecap_interrupt_msgnum
  .cfg_to_turnoff(cfg_to_turnoff),                                                          // output wire cfg_to_turnoff
  .cfg_turnoff_ok(cfg_turnoff_ok),                                                          // input wire cfg_turnoff_ok
  .cfg_bus_number(cfg_bus_number),                                                          // output wire [7 : 0] cfg_bus_number
  .cfg_device_number(cfg_device_number),                                                    // output wire [4 : 0] cfg_device_number
  .cfg_function_number(cfg_function_number),                                                // output wire [2 : 0] cfg_function_number
  .cfg_pm_wake(cfg_pm_wake),                                                                // input wire cfg_pm_wake
  .cfg_pm_send_pme_to(cfg_pm_send_pme_to),                                                  // input wire cfg_pm_send_pme_to
  .cfg_ds_bus_number(cfg_ds_bus_number),                                                    // input wire [7 : 0] cfg_ds_bus_number
  .cfg_ds_device_number(cfg_ds_device_number),                                              // input wire [4 : 0] cfg_ds_device_number
  .cfg_ds_function_number(cfg_ds_function_number),                                          // input wire [2 : 0] cfg_ds_function_number
  .cfg_mgmt_wr_rw1c_as_rw(cfg_mgmt_wr_rw1c_as_rw),                                          // input wire cfg_mgmt_wr_rw1c_as_rw
  .cfg_bridge_serr_en(cfg_bridge_serr_en),                                                  // output wire cfg_bridge_serr_en
  .cfg_slot_control_electromech_il_ctl_pulse(cfg_slot_control_electromech_il_ctl_pulse),    // output wire cfg_slot_control_electromech_il_ctl_pulse
  .cfg_root_control_syserr_corr_err_en(cfg_root_control_syserr_corr_err_en),                // output wire cfg_root_control_syserr_corr_err_en
  .cfg_root_control_syserr_non_fatal_err_en(cfg_root_control_syserr_non_fatal_err_en),      // output wire cfg_root_control_syserr_non_fatal_err_en
  .cfg_root_control_syserr_fatal_err_en(cfg_root_control_syserr_fatal_err_en),              // output wire cfg_root_control_syserr_fatal_err_en
  .cfg_root_control_pme_int_en(cfg_root_control_pme_int_en),                                // output wire cfg_root_control_pme_int_en
  .cfg_aer_rooterr_corr_err_reporting_en(cfg_aer_rooterr_corr_err_reporting_en),            // output wire cfg_aer_rooterr_corr_err_reporting_en
  .cfg_aer_rooterr_non_fatal_err_reporting_en(cfg_aer_rooterr_non_fatal_err_reporting_en),  // output wire cfg_aer_rooterr_non_fatal_err_reporting_en
  .cfg_aer_rooterr_fatal_err_reporting_en(cfg_aer_rooterr_fatal_err_reporting_en),          // output wire cfg_aer_rooterr_fatal_err_reporting_en
  .cfg_aer_rooterr_corr_err_received(cfg_aer_rooterr_corr_err_received),                    // output wire cfg_aer_rooterr_corr_err_received
  .cfg_aer_rooterr_non_fatal_err_received(cfg_aer_rooterr_non_fatal_err_received),          // output wire cfg_aer_rooterr_non_fatal_err_received
  .cfg_aer_rooterr_fatal_err_received(cfg_aer_rooterr_fatal_err_received),                  // output wire cfg_aer_rooterr_fatal_err_received
  .pl_directed_link_change(pl_directed_link_change),                                        // input wire [1 : 0] pl_directed_link_change
  .pl_directed_link_width(pl_directed_link_width),                                          // input wire [1 : 0] pl_directed_link_width
  .pl_directed_link_speed(pl_directed_link_speed),                                          // input wire pl_directed_link_speed
  .pl_directed_link_auton(pl_directed_link_auton),                                          // input wire pl_directed_link_auton
  .pl_upstream_prefer_deemph(pl_upstream_prefer_deemph),                                    // input wire pl_upstream_prefer_deemph
  .pl_sel_lnk_rate(pl_sel_lnk_rate),                                                        // output wire pl_sel_lnk_rate
  .pl_sel_lnk_width(pl_sel_lnk_width),                                                      // output wire [1 : 0] pl_sel_lnk_width
  .pl_ltssm_state(pl_ltssm_state),                                                          // output wire [5 : 0] pl_ltssm_state
  .pl_lane_reversal_mode(pl_lane_reversal_mode),                                            // output wire [1 : 0] pl_lane_reversal_mode
  .pl_phy_lnk_up(pl_phy_lnk_up),                                                            // output wire pl_phy_lnk_up
  .pl_tx_pm_state(pl_tx_pm_state),                                                          // output wire [2 : 0] pl_tx_pm_state
  .pl_rx_pm_state(pl_rx_pm_state),                                                          // output wire [1 : 0] pl_rx_pm_state
  .pl_link_upcfg_cap(pl_link_upcfg_cap),                                                    // output wire pl_link_upcfg_cap
  .pl_link_gen2_cap(pl_link_gen2_cap),                                                      // output wire pl_link_gen2_cap
  .pl_link_partner_gen2_supported(pl_link_partner_gen2_supported),                          // output wire pl_link_partner_gen2_supported
  .pl_initial_link_width(pl_initial_link_width),                                            // output wire [2 : 0] pl_initial_link_width
  .pl_directed_change_done(pl_directed_change_done),                                        // output wire pl_directed_change_done
  .pl_received_hot_rst(pl_received_hot_rst),                                                // output wire pl_received_hot_rst
  .pl_transmit_hot_rst(pl_transmit_hot_rst),                                                // input wire pl_transmit_hot_rst
  .pl_downstream_deemph_source(pl_downstream_deemph_source),                                // input wire pl_downstream_deemph_source
  .cfg_vc_tcvc_map(cfg_vc_tcvc_map),                                                        // output wire [6 : 0] cfg_vc_tcvc_map
  .sys_clk(sys_clk),                                                                        // input wire sys_clk
  .sys_rst_n(sys_rst_n)                                                                    // input wire sys_rst_n
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file pcie_7x_0.v when simulating
// the core, pcie_7x_0. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

