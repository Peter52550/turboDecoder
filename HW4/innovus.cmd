#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Thu Mar 25 18:09:12 2021                
#                                                     
#######################################################

#@(#)CDS: Innovus v17.11-s080_1 (64bit) 08/04/2017 11:13 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 17.11-s080_1 NR170721-2155/17_11-UB (database version 2.30, 390.7.1) {superthreading v1.44}
#@(#)CDS: AAE 17.11-s034 (64bit) 08/04/2017 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 17.11-s053_1 () Aug  1 2017 23:31:41 ( )
#@(#)CDS: SYNTECH 17.11-s012_1 () Jul 21 2017 02:29:12 ( )
#@(#)CDS: CPE v17.11-s095
#@(#)CDS: IQRC/TQRC 16.1.1-s215 (64bit) Thu Jul  6 20:18:10 PDT 2017 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set init_gnd_net GND
set init_lef_file {lef/header6_V55_20ka_cic.lef lef/fsa0m_a_generic_core.lef lef/FSA0M_A_GENERIC_CORE_ANT_V55.lef lef/fsa0m_a_t33_generic_io.lef lef/FSA0M_A_T33_GENERIC_IO_ANT_V55.lef lef/BONDPAD.lef}
set init_verilog design/CHIP_syn.v
set init_mmmc_file mmmc.view
set init_io_file design/CHIP.ioc
set init_top_cell CHIP
set init_pwr_net VCC
init_design
clearGlobalNets
globalNetConnect VCC -type pgpin -pin VCC -inst *
globalNetConnect GND -type pgpin -pin GND -inst *
clearGlobalNets
globalNetConnect VCC -type pgpin -pin VCC -inst *
globalNetConnect GND -type pgpin -pin GND -inst *
clearGlobalNets
globalNetConnect VCC -type pgpin -pin VCC -inst *
globalNetConnect GND -type pgpin -pin GND -inst *
clearGlobalNets
globalNetConnect VCC -type pgpin -pin VCC -inst *
globalNetConnect GND -type pgpin -pin GND -inst *
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site core_5040 -r 1 0.01 80 80 80 80
uiSetTool select
getIoFlowFlag
fit
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer metal6 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VCC GND} -type core_rings -follow core -layer {top metal5 bottom metal5 left metal4 right metal4} -width {top 2 bottom 2 left 2 right 2} -spacing {top 0.28 bottom 0.28 left 0.28 right 0.28} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None -use_wire_group 1 -use_wire_group_bits 15 -use_interleaving_wire_group 1
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { padPin } -layerChangeRange { metal1(1) metal6(6) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -allowJogging 1 -crossoverViaLayerRange { metal1(1) metal6(6) } -nets { VCC GND } -allowLayerChange 1 -targetViaLayerRange { metal1(1) metal6(6) }
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length 0 -stacked_via_top_layer metal6 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring }
addStripe -nets {VCC GND} -layer metal4 -direction vertical -width 1 -spacing 0.28 -set_to_set_distance 400 -start_from left -start_offset 250 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit metal6 -padcore_ring_bottom_layer_limit metal1 -block_ring_top_layer_limit metal6 -block_ring_bottom_layer_limit metal1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { metal1(1) metal6(6) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { metal1(1) metal6(6) } -nets { GND VCC } -allowLayerChange 1 -targetViaLayerRange { metal1(1) metal6(6) }
addIoFiller -cell EMPTY16D -prefix IOFILLER
addIoFiller -cell EMPTY8D -prefix IOFILLER
addIoFiller -cell EMPTY4D -prefix IOFILLER
addIoFiller -cell EMPTY2D -prefix IOFILLER
addIoFiller -cell EMPTY1D -prefix IOFILLER -fillAnyGap
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
verifyConnectivity -nets ANTENNA -type special -noUnroutedNet -error 1000 -warning 50
verifyConnectivity -nets {VCC GND} -type special -noUnroutedNet -error 1000 -warning 50
saveDesign DBS/powerroute
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setUsefulSkewMode -maxSkew false -noBoundary false -useCells {DELC DELB DELA BUF8CK BUF8 BUF6CK BUF6 BUF4CK BUF4 BUF3CK BUF3 BUF2CK BUF2 BUF1S BUF1CK BUF12CK BUF1 INV8CK INV8 INV6CK INV6 INV4CK INV4 INV3CK INV3 INV2CK INV2 INV1S INV1CK INV12CK INV12 INV1} -maxAllowedDelay 1
setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -modulePlan 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 0 -moduleAwareSpare 0 -maxDensity 0.6 -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setPlaceMode -fp false
placeDesign
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports
saveDesign DBS/placement
create_ccopt_clock_tree_spec -file ccopt.spec
ccopt_check_and_flatten_ilms_no_restore
set_ccopt_property case_analysis -pin ipad_clk_p_i/PD 0
set_ccopt_property case_analysis -pin ipad_clk_p_i/PU 0
set_ccopt_property case_analysis -pin ipad_clk_p_i/SMT 0
create_ccopt_clock_tree -name clk_p_i -source clk_p_i -no_skew_group
set_ccopt_property clock_period -pin clk_p_i 10
create_ccopt_skew_group -name clk_p_i/func_mode -sources clk_p_i -auto_sinks
set_ccopt_property include_source_latency -skew_group clk_p_i/func_mode true
set_ccopt_property target_insertion_delay -skew_group clk_p_i/func_mode 0.500
set_ccopt_property extracted_from_clock_name -skew_group clk_p_i/func_mode clk_p_i
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk_p_i/func_mode func_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk_p_i/func_mode {DC_max DC_min}
create_ccopt_skew_group -name clk_p_i/scan_mode -sources clk_p_i -auto_sinks
set_ccopt_property include_source_latency -skew_group clk_p_i/scan_mode true
set_ccopt_property target_insertion_delay -skew_group clk_p_i/scan_mode 0.500
set_ccopt_property extracted_from_clock_name -skew_group clk_p_i/scan_mode clk_p_i
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk_p_i/scan_mode scan_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk_p_i/scan_mode {DC_max DC_min}
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design -cts
getCTSMode -engine -quiet
ctd_win -id ctd_window
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
saveDesign DBS/cts
setNanoRouteMode -quiet -routeInsertAntennaDiode 1
setNanoRouteMode -quiet -routeAntennaCellName ANTENNA
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeWithSiPostRouteFix 1
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail -viaOpt -wireOpt
setLayerPreference violation -isVisible 1
violationBrowser -all -no_display_false
clearDrc
setAnalysisMode -analysisType onChipVariation
violationBrowserClose
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
saveDesign DBS/route
getFillerMode -quiet
addFiller -cell FILLER64 FILLER32 FILLER16 FILLER8 FILLER4 FILLER2 FILLER1 -prefix FILLER
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
verifyProcessAntenna -reportfile CHIP.antenna.rpt -error 1000
verifyConnectivity -nets {VCC GND} -type special -noUnroutedNet -error 1000 -warning 50
saveNetlist CHIP.v
setAnalysisMode -analysisType bcwc
write_sdf -max_view av_func_mode_max -min_view av_func_mode_min -edges noedge -splitsetuphold -remashold -splitrecrem -min_period_edges none CHIP.sdf
set dbgLefDefOutVersion 5.8
global dbgLefDefOutVersion
set dbgLefDefOutVersion 5.8
defOut -floorplan -netlist -scanChain -routing CHIP.def
set dbgLefDefOutVersion 5.8
set dbgLefDefOutVersion 5.8
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_0 -loc 187.47 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_1 -loc 297.44 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_2 -loc 407.41 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_3 -loc 517.37 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_CoreVSS2 -loc 627.33 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_CoreVDD2 -loc 737.29 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_4 -loc 847.25 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_5 -loc 957.21 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_6 -loc 1067.18 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_7 -loc 1177.15 -56.92 -ori R0
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_8 -loc 1427.24 186.68 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_9 -loc 1427.24 295.86 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_10 -loc 1427.24 405.04 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_11 -loc 1427.24 514.22 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_IOVDD2 -loc 1427.24 623.4 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_IOVSS2 -loc 1427.24 732.58 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_12 -loc 1427.24 841.76 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_13 -loc 1427.24 950.94 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_14 -loc 1427.24 1060.12 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_o_15 -loc 1427.24 1169.3 -ori R90
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_4 -loc 1194.07 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_3 -loc 1101.02 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_2 -loc 1007.97 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_1 -loc 914.92 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_0 -loc 821.87 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_CoreVSS1 -loc 728.83 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_CoreVDD1 -loc 635.79 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_inst_i_2 -loc 542.75 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_inst_i_1 -loc 449.7 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_inst_i_0 -loc 356.65 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_reset_n_i -loc 263.6 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_clk_p_i -loc 170.55 1418.6 -ori R180
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_7 -loc -56.92 1192.69 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_6 -loc -56.92 1106.9 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_5 -loc -56.92 1021.11 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_4 -loc -56.92 935.33 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_3 -loc -56.92 849.55 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_2 -loc -56.92 763.77 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_IOVSS1 -loc -56.92 677.99 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_IOVDD1 -loc -56.92 592.21 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_1 -loc -56.92 506.43 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_b_i_0 -loc -56.92 420.65 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_7 -loc -56.92 334.87 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_6 -loc -56.92 249.08 -ori R270
addInst -physical -cell BONDPADD_m -inst BPad_ipad_data_a_i_5 -loc -56.92 163.29 -ori R270
setDrawView place
redraw
add_text -layer metal5 -pt 1435 640 -label IOVDD -height 10
add_text -layer metal5 -pt 1435 750 -label IOVSS -height 10
saveDesign DBS/finish
addMetalFill -layer { metal1 metal2 metal3 metal4 metal5 metal6 } -timingAware sta -slackThreshold 0.2
setStreamOutMode -specifyViaName default -SEvianames false -virtualConnection false -uniquifyCellNamesPrefix false -snapToMGrid false -textSize 1 -version 3
streamOut CHIP.gds -mapFile streamOut.map -merge { ./Phantom/fsa0m_a_generic_core_cic.gds ./Phantom/fsa0m_a_t33_generic_io_cic.gds ./Phantom/BONDPAD.gds} -stripes 1 -units 1000 -mode ALL
