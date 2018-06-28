-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
-- Date        : Mon Jun 25 19:22:55 2018
-- Host        : ubuntu running 64-bit Ubuntu 16.04.4 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top pcie_7x_0 -prefix
--               pcie_7x_0_ pcie_7x_0_stub.vhdl
-- Design      : pcie_7x_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a50tcsg325-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pcie_7x_0 is
  Port ( 
    pci_exp_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    pci_exp_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    pci_exp_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    pci_exp_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    user_clk_out : out STD_LOGIC;
    user_reset_out : out STD_LOGIC;
    user_lnk_up : out STD_LOGIC;
    user_app_rdy : out STD_LOGIC;
    tx_buf_av : out STD_LOGIC_VECTOR ( 5 downto 0 );
    tx_cfg_req : out STD_LOGIC;
    tx_err_drop : out STD_LOGIC;
    s_axis_tx_tready : out STD_LOGIC;
    s_axis_tx_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tx_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tx_tlast : in STD_LOGIC;
    s_axis_tx_tvalid : in STD_LOGIC;
    s_axis_tx_tuser : in STD_LOGIC_VECTOR ( 3 downto 0 );
    tx_cfg_gnt : in STD_LOGIC;
    m_axis_rx_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_rx_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_rx_tlast : out STD_LOGIC;
    m_axis_rx_tvalid : out STD_LOGIC;
    m_axis_rx_tready : in STD_LOGIC;
    m_axis_rx_tuser : out STD_LOGIC_VECTOR ( 21 downto 0 );
    rx_np_ok : in STD_LOGIC;
    rx_np_req : in STD_LOGIC;
    cfg_mgmt_do : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_rd_wr_done : out STD_LOGIC;
    cfg_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_command : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dcommand2 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_pcie_link_state : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_pmcsr_pme_en : out STD_LOGIC;
    cfg_pmcsr_powerstate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_pmcsr_pme_status : out STD_LOGIC;
    cfg_received_func_lvl_rst : out STD_LOGIC;
    cfg_mgmt_di : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_byte_en : in STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_mgmt_dwaddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_mgmt_wr_en : in STD_LOGIC;
    cfg_mgmt_rd_en : in STD_LOGIC;
    cfg_mgmt_wr_readonly : in STD_LOGIC;
    cfg_trn_pending : in STD_LOGIC;
    cfg_pm_halt_aspm_l0s : in STD_LOGIC;
    cfg_pm_halt_aspm_l1 : in STD_LOGIC;
    cfg_pm_force_state_en : in STD_LOGIC;
    cfg_pm_force_state : in STD_LOGIC_VECTOR ( 1 downto 0 );
    cfg_dsn : in STD_LOGIC_VECTOR ( 63 downto 0 );
    cfg_interrupt : in STD_LOGIC;
    cfg_interrupt_rdy : out STD_LOGIC;
    cfg_interrupt_assert : in STD_LOGIC;
    cfg_interrupt_di : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_interrupt_do : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_interrupt_mmenable : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_interrupt_msienable : out STD_LOGIC;
    cfg_interrupt_msixenable : out STD_LOGIC;
    cfg_interrupt_msixfm : out STD_LOGIC;
    cfg_interrupt_stat : in STD_LOGIC;
    cfg_pciecap_interrupt_msgnum : in STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_to_turnoff : out STD_LOGIC;
    cfg_turnoff_ok : in STD_LOGIC;
    cfg_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_device_number : out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_function_number : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_pm_wake : in STD_LOGIC;
    cfg_pm_send_pme_to : in STD_LOGIC;
    cfg_ds_bus_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_ds_device_number : in STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_ds_function_number : in STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_mgmt_wr_rw1c_as_rw : in STD_LOGIC;
    cfg_bridge_serr_en : out STD_LOGIC;
    cfg_slot_control_electromech_il_ctl_pulse : out STD_LOGIC;
    cfg_root_control_syserr_corr_err_en : out STD_LOGIC;
    cfg_root_control_syserr_non_fatal_err_en : out STD_LOGIC;
    cfg_root_control_syserr_fatal_err_en : out STD_LOGIC;
    cfg_root_control_pme_int_en : out STD_LOGIC;
    cfg_aer_rooterr_corr_err_reporting_en : out STD_LOGIC;
    cfg_aer_rooterr_non_fatal_err_reporting_en : out STD_LOGIC;
    cfg_aer_rooterr_fatal_err_reporting_en : out STD_LOGIC;
    cfg_aer_rooterr_corr_err_received : out STD_LOGIC;
    cfg_aer_rooterr_non_fatal_err_received : out STD_LOGIC;
    cfg_aer_rooterr_fatal_err_received : out STD_LOGIC;
    pl_directed_link_change : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pl_directed_link_width : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pl_directed_link_speed : in STD_LOGIC;
    pl_directed_link_auton : in STD_LOGIC;
    pl_upstream_prefer_deemph : in STD_LOGIC;
    pl_sel_lnk_rate : out STD_LOGIC;
    pl_sel_lnk_width : out STD_LOGIC_VECTOR ( 1 downto 0 );
    pl_ltssm_state : out STD_LOGIC_VECTOR ( 5 downto 0 );
    pl_lane_reversal_mode : out STD_LOGIC_VECTOR ( 1 downto 0 );
    pl_phy_lnk_up : out STD_LOGIC;
    pl_tx_pm_state : out STD_LOGIC_VECTOR ( 2 downto 0 );
    pl_rx_pm_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
    pl_link_upcfg_cap : out STD_LOGIC;
    pl_link_gen2_cap : out STD_LOGIC;
    pl_link_partner_gen2_supported : out STD_LOGIC;
    pl_initial_link_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
    pl_directed_change_done : out STD_LOGIC;
    pl_received_hot_rst : out STD_LOGIC;
    pl_transmit_hot_rst : in STD_LOGIC;
    pl_downstream_deemph_source : in STD_LOGIC;
    cfg_vc_tcvc_map : out STD_LOGIC_VECTOR ( 6 downto 0 );
    sys_clk : in STD_LOGIC;
    sys_rst_n : in STD_LOGIC
  );

end pcie_7x_0;

architecture stub of pcie_7x_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "pci_exp_txp[0:0],pci_exp_txn[0:0],pci_exp_rxp[0:0],pci_exp_rxn[0:0],user_clk_out,user_reset_out,user_lnk_up,user_app_rdy,tx_buf_av[5:0],tx_cfg_req,tx_err_drop,s_axis_tx_tready,s_axis_tx_tdata[63:0],s_axis_tx_tkeep[7:0],s_axis_tx_tlast,s_axis_tx_tvalid,s_axis_tx_tuser[3:0],tx_cfg_gnt,m_axis_rx_tdata[63:0],m_axis_rx_tkeep[7:0],m_axis_rx_tlast,m_axis_rx_tvalid,m_axis_rx_tready,m_axis_rx_tuser[21:0],rx_np_ok,rx_np_req,cfg_mgmt_do[31:0],cfg_mgmt_rd_wr_done,cfg_status[15:0],cfg_command[15:0],cfg_dstatus[15:0],cfg_dcommand[15:0],cfg_lstatus[15:0],cfg_lcommand[15:0],cfg_dcommand2[15:0],cfg_pcie_link_state[2:0],cfg_pmcsr_pme_en,cfg_pmcsr_powerstate[1:0],cfg_pmcsr_pme_status,cfg_received_func_lvl_rst,cfg_mgmt_di[31:0],cfg_mgmt_byte_en[3:0],cfg_mgmt_dwaddr[9:0],cfg_mgmt_wr_en,cfg_mgmt_rd_en,cfg_mgmt_wr_readonly,cfg_trn_pending,cfg_pm_halt_aspm_l0s,cfg_pm_halt_aspm_l1,cfg_pm_force_state_en,cfg_pm_force_state[1:0],cfg_dsn[63:0],cfg_interrupt,cfg_interrupt_rdy,cfg_interrupt_assert,cfg_interrupt_di[7:0],cfg_interrupt_do[7:0],cfg_interrupt_mmenable[2:0],cfg_interrupt_msienable,cfg_interrupt_msixenable,cfg_interrupt_msixfm,cfg_interrupt_stat,cfg_pciecap_interrupt_msgnum[4:0],cfg_to_turnoff,cfg_turnoff_ok,cfg_bus_number[7:0],cfg_device_number[4:0],cfg_function_number[2:0],cfg_pm_wake,cfg_pm_send_pme_to,cfg_ds_bus_number[7:0],cfg_ds_device_number[4:0],cfg_ds_function_number[2:0],cfg_mgmt_wr_rw1c_as_rw,cfg_bridge_serr_en,cfg_slot_control_electromech_il_ctl_pulse,cfg_root_control_syserr_corr_err_en,cfg_root_control_syserr_non_fatal_err_en,cfg_root_control_syserr_fatal_err_en,cfg_root_control_pme_int_en,cfg_aer_rooterr_corr_err_reporting_en,cfg_aer_rooterr_non_fatal_err_reporting_en,cfg_aer_rooterr_fatal_err_reporting_en,cfg_aer_rooterr_corr_err_received,cfg_aer_rooterr_non_fatal_err_received,cfg_aer_rooterr_fatal_err_received,pl_directed_link_change[1:0],pl_directed_link_width[1:0],pl_directed_link_speed,pl_directed_link_auton,pl_upstream_prefer_deemph,pl_sel_lnk_rate,pl_sel_lnk_width[1:0],pl_ltssm_state[5:0],pl_lane_reversal_mode[1:0],pl_phy_lnk_up,pl_tx_pm_state[2:0],pl_rx_pm_state[1:0],pl_link_upcfg_cap,pl_link_gen2_cap,pl_link_partner_gen2_supported,pl_initial_link_width[2:0],pl_directed_change_done,pl_received_hot_rst,pl_transmit_hot_rst,pl_downstream_deemph_source,cfg_vc_tcvc_map[6:0],sys_clk,sys_rst_n";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "pcie_7x_0_pcie2_top,Vivado 2018.1";
begin
end;
