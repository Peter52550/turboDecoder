/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP2
// Date      : Thu Mar 18 11:32:45 2021
/////////////////////////////////////////////////////////////


module alu_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  FA1S U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6]) );
  FA1S U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5]) );
  FA1S U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4]) );
  FA1S U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3]) );
  FA1S U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2]) );
  FA1S U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  FA1S U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  AN2 U1 ( .I1(B[0]), .I2(A[0]), .O(n1) );
  XOR2HS U2 ( .I1(B[0]), .I2(A[0]), .O(SUM[0]) );
endmodule


module alu_DW01_sub_0 ( A, B, CI, DIFF, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] DIFF;
  input CI;
  output CO;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;
  wire   [9:0] carry;

  FA1S U2_7 ( .A(A[7]), .B(n2), .CI(carry[7]), .CO(carry[8]), .S(DIFF[7]) );
  FA1S U2_6 ( .A(A[6]), .B(n3), .CI(carry[6]), .CO(carry[7]), .S(DIFF[6]) );
  FA1S U2_5 ( .A(A[5]), .B(n4), .CI(carry[5]), .CO(carry[6]), .S(DIFF[5]) );
  FA1S U2_4 ( .A(A[4]), .B(n5), .CI(carry[4]), .CO(carry[5]), .S(DIFF[4]) );
  FA1S U2_3 ( .A(A[3]), .B(n6), .CI(carry[3]), .CO(carry[4]), .S(DIFF[3]) );
  FA1S U2_2 ( .A(A[2]), .B(n7), .CI(carry[2]), .CO(carry[3]), .S(DIFF[2]) );
  FA1S U2_1 ( .A(A[1]), .B(n8), .CI(carry[1]), .CO(carry[2]), .S(DIFF[1]) );
  XNR2HS U1 ( .I1(n9), .I2(A[0]), .O(DIFF[0]) );
  INV1S U2 ( .I(B[0]), .O(n9) );
  INV1S U3 ( .I(B[1]), .O(n8) );
  INV1S U4 ( .I(B[2]), .O(n7) );
  INV1S U5 ( .I(B[3]), .O(n6) );
  INV1S U6 ( .I(B[4]), .O(n5) );
  INV1S U7 ( .I(B[5]), .O(n4) );
  INV1S U8 ( .I(B[6]), .O(n3) );
  INV1S U9 ( .I(B[7]), .O(n2) );
  INV1S U10 ( .I(A[0]), .O(n1) );
  ND2 U11 ( .I1(B[0]), .I2(n1), .O(carry[1]) );
  INV1S U12 ( .I(carry[8]), .O(DIFF[8]) );
endmodule


module alu_DW01_inc_0 ( A, SUM );
  input [7:0] A;
  output [7:0] SUM;

  wire   [7:2] carry;

  HA1 U1_1_6 ( .A(A[6]), .B(carry[6]), .C(carry[7]), .S(SUM[6]) );
  HA1 U1_1_5 ( .A(A[5]), .B(carry[5]), .C(carry[6]), .S(SUM[5]) );
  HA1 U1_1_4 ( .A(A[4]), .B(carry[4]), .C(carry[5]), .S(SUM[4]) );
  HA1 U1_1_3 ( .A(A[3]), .B(carry[3]), .C(carry[4]), .S(SUM[3]) );
  HA1 U1_1_2 ( .A(A[2]), .B(carry[2]), .C(carry[3]), .S(SUM[2]) );
  HA1 U1_1_1 ( .A(A[1]), .B(A[0]), .C(carry[2]), .S(SUM[1]) );
  XOR2HS U1 ( .I1(carry[7]), .I2(A[7]), .O(SUM[7]) );
  INV1S U2 ( .I(A[0]), .O(SUM[0]) );
endmodule


module alu_DW_mult_uns_0 ( a, b, product );
  input [7:0] a;
  input [7:0] b;
  output [15:0] product;
  wire   n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153, n154, n155,
         n156, n157, n158, n159, n160, n161, n214, n215, n216, n217, n218,
         n219, n220, n221, n222, n223, n224, n225, n226, n227, n228, n229,
         n230, n231, n232, n233, n234, n235, n236, n237, n238, n239, n240,
         n241, n242, n243, n244, n245, n246, n247;

  FA1S U2 ( .A(n99), .B(n15), .CI(n2), .CO(product[15]), .S(product[14]) );
  FA1S U3 ( .A(n16), .B(n17), .CI(n3), .CO(n2), .S(product[13]) );
  FA1S U4 ( .A(n18), .B(n21), .CI(n4), .CO(n3), .S(product[12]) );
  FA1S U5 ( .A(n27), .B(n22), .CI(n5), .CO(n4), .S(product[11]) );
  FA1S U6 ( .A(n35), .B(n28), .CI(n6), .CO(n5), .S(product[10]) );
  FA1S U7 ( .A(n45), .B(n36), .CI(n7), .CO(n6), .S(product[9]) );
  FA1S U8 ( .A(n57), .B(n46), .CI(n8), .CO(n7), .S(product[8]) );
  FA1S U9 ( .A(n69), .B(n58), .CI(n9), .CO(n8), .S(product[7]) );
  FA1S U10 ( .A(n79), .B(n70), .CI(n10), .CO(n9), .S(product[6]) );
  FA1S U11 ( .A(n87), .B(n80), .CI(n11), .CO(n10), .S(product[5]) );
  FA1S U12 ( .A(n93), .B(n88), .CI(n12), .CO(n11), .S(product[4]) );
  FA1S U13 ( .A(n96), .B(n13), .CI(n94), .CO(n12), .S(product[3]) );
  FA1S U14 ( .A(n146), .B(n14), .CI(n98), .CO(n13), .S(product[2]) );
  HA1 U15 ( .A(n154), .B(n161), .C(n14), .S(product[1]) );
  FA1S U16 ( .A(n107), .B(n100), .CI(n19), .CO(n15), .S(n16) );
  FA1S U17 ( .A(n25), .B(n20), .CI(n23), .CO(n17), .S(n18) );
  FA1S U18 ( .A(n115), .B(n101), .CI(n108), .CO(n19), .S(n20) );
  FA1S U19 ( .A(n31), .B(n24), .CI(n29), .CO(n21), .S(n22) );
  FA1S U20 ( .A(n116), .B(n33), .CI(n26), .CO(n23), .S(n24) );
  FA1S U21 ( .A(n123), .B(n102), .CI(n109), .CO(n25), .S(n26) );
  FA1S U22 ( .A(n32), .B(n37), .CI(n30), .CO(n27), .S(n28) );
  FA1S U23 ( .A(n41), .B(n34), .CI(n39), .CO(n29), .S(n30) );
  FA1S U24 ( .A(n124), .B(n117), .CI(n43), .CO(n31), .S(n32) );
  FA1S U25 ( .A(n131), .B(n103), .CI(n110), .CO(n33), .S(n34) );
  FA1S U26 ( .A(n40), .B(n47), .CI(n38), .CO(n35), .S(n36) );
  FA1S U27 ( .A(n44), .B(n51), .CI(n49), .CO(n37), .S(n38) );
  FA1S U28 ( .A(n55), .B(n53), .CI(n42), .CO(n39), .S(n40) );
  FA1S U29 ( .A(n118), .B(n125), .CI(n132), .CO(n41), .S(n42) );
  FA1S U30 ( .A(n139), .B(n104), .CI(n111), .CO(n43), .S(n44) );
  FA1S U31 ( .A(n50), .B(n59), .CI(n48), .CO(n45), .S(n46) );
  FA1S U32 ( .A(n54), .B(n52), .CI(n61), .CO(n47), .S(n48) );
  FA1S U33 ( .A(n56), .B(n65), .CI(n63), .CO(n49), .S(n50) );
  FA1S U34 ( .A(n140), .B(n133), .CI(n67), .CO(n51), .S(n52) );
  FA1S U35 ( .A(n126), .B(n119), .CI(n147), .CO(n53), .S(n54) );
  HA1 U36 ( .A(n112), .B(n105), .C(n55), .S(n56) );
  FA1S U37 ( .A(n71), .B(n62), .CI(n60), .CO(n57), .S(n58) );
  FA1S U38 ( .A(n64), .B(n66), .CI(n73), .CO(n59), .S(n60) );
  FA1S U39 ( .A(n77), .B(n68), .CI(n75), .CO(n61), .S(n62) );
  FA1S U40 ( .A(n141), .B(n127), .CI(n134), .CO(n63), .S(n64) );
  FA1S U41 ( .A(n155), .B(n120), .CI(n148), .CO(n65), .S(n66) );
  HA1 U42 ( .A(n113), .B(n106), .C(n67), .S(n68) );
  FA1S U43 ( .A(n81), .B(n74), .CI(n72), .CO(n69), .S(n70) );
  FA1S U44 ( .A(n78), .B(n83), .CI(n76), .CO(n71), .S(n72) );
  FA1S U45 ( .A(n142), .B(n135), .CI(n85), .CO(n73), .S(n74) );
  FA1S U46 ( .A(n156), .B(n128), .CI(n149), .CO(n75), .S(n76) );
  HA1 U47 ( .A(n121), .B(n114), .C(n77), .S(n78) );
  FA1S U48 ( .A(n89), .B(n84), .CI(n82), .CO(n79), .S(n80) );
  FA1S U49 ( .A(n150), .B(n91), .CI(n86), .CO(n81), .S(n82) );
  FA1S U50 ( .A(n157), .B(n136), .CI(n143), .CO(n83), .S(n84) );
  HA1 U51 ( .A(n129), .B(n122), .C(n85), .S(n86) );
  FA1S U52 ( .A(n95), .B(n92), .CI(n90), .CO(n87), .S(n88) );
  FA1S U53 ( .A(n158), .B(n144), .CI(n151), .CO(n89), .S(n90) );
  HA1 U54 ( .A(n137), .B(n130), .C(n91), .S(n92) );
  FA1S U55 ( .A(n159), .B(n152), .CI(n97), .CO(n93), .S(n94) );
  HA1 U56 ( .A(n145), .B(n138), .C(n95), .S(n96) );
  HA1 U57 ( .A(n160), .B(n153), .C(n97), .S(n98) );
  INV1S U140 ( .I(n246), .O(n214) );
  INV1S U141 ( .I(n214), .O(n215) );
  INV1S U142 ( .I(n247), .O(n216) );
  INV1S U143 ( .I(n216), .O(n217) );
  INV1S U144 ( .I(a[7]), .O(n218) );
  INV1S U145 ( .I(a[7]), .O(n219) );
  INV1S U146 ( .I(b[5]), .O(n220) );
  INV1S U147 ( .I(b[5]), .O(n221) );
  INV1S U148 ( .I(b[6]), .O(n222) );
  INV1S U149 ( .I(b[6]), .O(n223) );
  INV1S U150 ( .I(b[1]), .O(n224) );
  INV1S U151 ( .I(b[1]), .O(n225) );
  INV1S U152 ( .I(b[4]), .O(n226) );
  INV1S U153 ( .I(b[4]), .O(n227) );
  INV1S U154 ( .I(b[3]), .O(n228) );
  INV1S U155 ( .I(b[3]), .O(n229) );
  INV1S U156 ( .I(b[2]), .O(n230) );
  INV1S U157 ( .I(b[2]), .O(n231) );
  INV1S U158 ( .I(b[7]), .O(n232) );
  INV1S U159 ( .I(b[7]), .O(n233) );
  INV1S U160 ( .I(a[4]), .O(n234) );
  INV1S U161 ( .I(a[4]), .O(n235) );
  INV1S U162 ( .I(a[5]), .O(n236) );
  INV1S U163 ( .I(a[5]), .O(n237) );
  INV1S U164 ( .I(a[6]), .O(n238) );
  INV1S U165 ( .I(a[6]), .O(n239) );
  INV1S U166 ( .I(a[3]), .O(n240) );
  INV1S U167 ( .I(a[3]), .O(n241) );
  INV1S U168 ( .I(a[2]), .O(n242) );
  INV1S U169 ( .I(a[2]), .O(n243) );
  INV1S U170 ( .I(a[1]), .O(n244) );
  INV1S U171 ( .I(a[1]), .O(n245) );
  INV1S U172 ( .I(b[0]), .O(n246) );
  INV1S U173 ( .I(a[0]), .O(n247) );
  NR2 U174 ( .I1(n217), .I2(n246), .O(product[0]) );
  NR2 U175 ( .I1(n218), .I2(n232), .O(n99) );
  NR2 U176 ( .I1(n247), .I2(n224), .O(n161) );
  NR2 U177 ( .I1(n217), .I2(n230), .O(n160) );
  NR2 U178 ( .I1(n247), .I2(n228), .O(n159) );
  NR2 U179 ( .I1(n217), .I2(n226), .O(n158) );
  NR2 U180 ( .I1(n247), .I2(n220), .O(n157) );
  NR2 U181 ( .I1(n217), .I2(n222), .O(n156) );
  NR2 U182 ( .I1(n247), .I2(n233), .O(n155) );
  NR2 U183 ( .I1(n215), .I2(n244), .O(n154) );
  NR2 U184 ( .I1(n224), .I2(n245), .O(n153) );
  NR2 U185 ( .I1(n230), .I2(n244), .O(n152) );
  NR2 U186 ( .I1(n228), .I2(n245), .O(n151) );
  NR2 U187 ( .I1(n226), .I2(n244), .O(n150) );
  NR2 U188 ( .I1(n220), .I2(n245), .O(n149) );
  NR2 U189 ( .I1(n222), .I2(n244), .O(n148) );
  NR2 U190 ( .I1(n232), .I2(n245), .O(n147) );
  NR2 U191 ( .I1(n246), .I2(n242), .O(n146) );
  NR2 U192 ( .I1(n225), .I2(n243), .O(n145) );
  NR2 U193 ( .I1(n231), .I2(n242), .O(n144) );
  NR2 U194 ( .I1(n229), .I2(n243), .O(n143) );
  NR2 U195 ( .I1(n227), .I2(n242), .O(n142) );
  NR2 U196 ( .I1(n221), .I2(n243), .O(n141) );
  NR2 U197 ( .I1(n223), .I2(n242), .O(n140) );
  NR2 U198 ( .I1(n233), .I2(n243), .O(n139) );
  NR2 U199 ( .I1(n215), .I2(n240), .O(n138) );
  NR2 U200 ( .I1(n224), .I2(n241), .O(n137) );
  NR2 U201 ( .I1(n230), .I2(n240), .O(n136) );
  NR2 U202 ( .I1(n228), .I2(n241), .O(n135) );
  NR2 U203 ( .I1(n226), .I2(n240), .O(n134) );
  NR2 U204 ( .I1(n220), .I2(n241), .O(n133) );
  NR2 U205 ( .I1(n222), .I2(n240), .O(n132) );
  NR2 U206 ( .I1(n232), .I2(n241), .O(n131) );
  NR2 U207 ( .I1(n246), .I2(n234), .O(n130) );
  NR2 U208 ( .I1(n225), .I2(n235), .O(n129) );
  NR2 U209 ( .I1(n231), .I2(n234), .O(n128) );
  NR2 U210 ( .I1(n229), .I2(n235), .O(n127) );
  NR2 U211 ( .I1(n227), .I2(n234), .O(n126) );
  NR2 U212 ( .I1(n221), .I2(n235), .O(n125) );
  NR2 U213 ( .I1(n223), .I2(n234), .O(n124) );
  NR2 U214 ( .I1(n233), .I2(n235), .O(n123) );
  NR2 U215 ( .I1(n215), .I2(n236), .O(n122) );
  NR2 U216 ( .I1(n224), .I2(n237), .O(n121) );
  NR2 U217 ( .I1(n230), .I2(n236), .O(n120) );
  NR2 U218 ( .I1(n228), .I2(n237), .O(n119) );
  NR2 U219 ( .I1(n226), .I2(n236), .O(n118) );
  NR2 U220 ( .I1(n220), .I2(n237), .O(n117) );
  NR2 U221 ( .I1(n222), .I2(n236), .O(n116) );
  NR2 U222 ( .I1(n232), .I2(n237), .O(n115) );
  NR2 U223 ( .I1(n246), .I2(n238), .O(n114) );
  NR2 U224 ( .I1(n225), .I2(n239), .O(n113) );
  NR2 U225 ( .I1(n231), .I2(n238), .O(n112) );
  NR2 U226 ( .I1(n229), .I2(n239), .O(n111) );
  NR2 U227 ( .I1(n227), .I2(n238), .O(n110) );
  NR2 U228 ( .I1(n221), .I2(n239), .O(n109) );
  NR2 U229 ( .I1(n223), .I2(n238), .O(n108) );
  NR2 U230 ( .I1(n233), .I2(n239), .O(n107) );
  NR2 U231 ( .I1(n215), .I2(n219), .O(n106) );
  NR2 U232 ( .I1(n219), .I2(n225), .O(n105) );
  NR2 U233 ( .I1(n218), .I2(n231), .O(n104) );
  NR2 U234 ( .I1(n219), .I2(n229), .O(n103) );
  NR2 U235 ( .I1(n218), .I2(n227), .O(n102) );
  NR2 U236 ( .I1(n219), .I2(n221), .O(n101) );
  NR2 U237 ( .I1(n218), .I2(n223), .O(n100) );
endmodule


module alu ( clk_p_i, reset_n_i, data_a_i, data_b_i, inst_i, data_o );

  input [7:0] data_a_i;
  input [7:0] data_b_i;
  input [2:0] inst_i;
  output [15:0] data_o;
  input clk_p_i, reset_n_i;
  wire   \data_a_r[0] , out_inst_1_15, N31, N32, N33, N34, N35, N36, N37, N38,
         n2, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37,
         n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51,
         n52, n54, n55, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68,
         n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82,
         n83, n84, n85, n86, n87, n88, n89, N30, N29, N28, N27, N26, N25, N24,
         N23, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101,
         n102, n103, n104, n105, n106, n107, n108, n109, n110, n111, n112,
         n113, n114, n115, n116, n117, n118, n119, n120, n121, n122, n123,
         n124;
  wire   [7:0] data_a_w;
  wire   [7:0] data_b_w;
  wire   [7:0] data_b_r;
  wire   [8:0] out_inst_0;
  wire   [7:0] out_inst_1;
  wire   [15:0] out_inst_2;
  wire   [6:0] out_inst_3;
  wire   [2:0] state_r;
  wire   [2:0] inst_r;

  ND2 U70 ( .I1(inst_r[1]), .I2(n28), .O(n26) );
  ND2 U71 ( .I1(inst_r[0]), .I2(n28), .O(n30) );
  OA222 U72 ( .A1(n35), .A2(n36), .B1(n37), .B2(n38), .C1(n39), .C2(n117), .O(
        n34) );
  AO12 U73 ( .B1(n46), .B2(n104), .A1(n122), .O(n44) );
  ND2 U74 ( .I1(inst_r[2]), .I2(n28), .O(n31) );
  AO222 U80 ( .A1(out_inst_2[6]), .A2(n106), .B1(out_inst_3[6]), .B2(n92), 
        .C1(out_inst_0[6]), .C2(n103), .O(n59) );
  AO222 U82 ( .A1(out_inst_2[5]), .A2(n104), .B1(out_inst_3[5]), .B2(n93), 
        .C1(out_inst_0[5]), .C2(n102), .O(n63) );
  AO222 U84 ( .A1(out_inst_2[4]), .A2(n105), .B1(out_inst_3[4]), .B2(n92), 
        .C1(out_inst_0[4]), .C2(n103), .O(n67) );
  AO222 U86 ( .A1(out_inst_2[3]), .A2(n106), .B1(out_inst_3[3]), .B2(n93), 
        .C1(out_inst_0[3]), .C2(n102), .O(n71) );
  AO222 U88 ( .A1(out_inst_2[2]), .A2(n104), .B1(out_inst_3[2]), .B2(n92), 
        .C1(out_inst_0[2]), .C2(n103), .O(n75) );
  AO222 U90 ( .A1(out_inst_2[1]), .A2(n105), .B1(out_inst_3[1]), .B2(n93), 
        .C1(out_inst_0[1]), .C2(n102), .O(n79) );
  AO222 U98 ( .A1(out_inst_2[0]), .A2(n106), .B1(out_inst_3[0]), .B2(n92), 
        .C1(out_inst_0[0]), .C2(n103), .O(n83) );
  alu_DW01_add_0 add_64 ( .A({n2, out_inst_3, \data_a_r[0] }), .B({n2, 
        data_b_r}), .CI(n2), .SUM(out_inst_0) );
  alu_DW01_sub_0 r319 ( .A({n2, data_b_r}), .B({n2, out_inst_3, \data_a_r[0] }), .CI(n2), .DIFF({out_inst_1_15, out_inst_1}) );
  alu_DW01_inc_0 add_0_root_add_73_ni ( .A({N23, N24, N25, N26, N27, N28, N29, 
        N30}), .SUM({N38, N37, N36, N35, N34, N33, N32, N31}) );
  alu_DW_mult_uns_0 mult_66 ( .a({out_inst_3, \data_a_r[0] }), .b(data_b_r), 
        .product(out_inst_2) );
  QDFFRBN \data_b_r_reg[7]  ( .D(data_b_w[7]), .CK(clk_p_i), .RB(n112), .Q(
        data_b_r[7]) );
  QDFFRBN \data_b_r_reg[6]  ( .D(data_b_w[6]), .CK(clk_p_i), .RB(reset_n_i), 
        .Q(data_b_r[6]) );
  QDFFRBN \data_b_r_reg[5]  ( .D(data_b_w[5]), .CK(clk_p_i), .RB(n113), .Q(
        data_b_r[5]) );
  QDFFRBN \data_b_r_reg[4]  ( .D(data_b_w[4]), .CK(clk_p_i), .RB(n115), .Q(
        data_b_r[4]) );
  QDFFRBN \data_b_r_reg[3]  ( .D(data_b_w[3]), .CK(clk_p_i), .RB(n114), .Q(
        data_b_r[3]) );
  QDFFRBN \data_b_r_reg[2]  ( .D(data_b_w[2]), .CK(clk_p_i), .RB(n113), .Q(
        data_b_r[2]) );
  QDFFRBN \data_b_r_reg[1]  ( .D(data_b_w[1]), .CK(clk_p_i), .RB(n115), .Q(
        data_b_r[1]) );
  QDFFRBN \data_a_r_reg[7]  ( .D(data_a_w[7]), .CK(clk_p_i), .RB(n111), .Q(
        out_inst_3[6]) );
  QDFFRBN \data_a_r_reg[6]  ( .D(data_a_w[6]), .CK(clk_p_i), .RB(n111), .Q(
        out_inst_3[5]) );
  QDFFRBN \data_a_r_reg[5]  ( .D(data_a_w[5]), .CK(clk_p_i), .RB(n111), .Q(
        out_inst_3[4]) );
  QDFFRBN \data_a_r_reg[4]  ( .D(data_a_w[4]), .CK(clk_p_i), .RB(n111), .Q(
        out_inst_3[3]) );
  QDFFRBN \data_a_r_reg[3]  ( .D(data_a_w[3]), .CK(clk_p_i), .RB(n111), .Q(
        out_inst_3[2]) );
  QDFFRBN \data_a_r_reg[2]  ( .D(data_a_w[2]), .CK(clk_p_i), .RB(n111), .Q(
        out_inst_3[1]) );
  QDFFRBN \data_a_r_reg[1]  ( .D(data_a_w[1]), .CK(clk_p_i), .RB(n112), .Q(
        out_inst_3[0]) );
  QDFFRBN \data_a_r_reg[0]  ( .D(data_a_w[0]), .CK(clk_p_i), .RB(n112), .Q(
        \data_a_r[0] ) );
  QDFFRBN \data_b_r_reg[0]  ( .D(data_b_w[0]), .CK(clk_p_i), .RB(n114), .Q(
        data_b_r[0]) );
  QDFFRBN \inst_r_reg[0]  ( .D(inst_i[0]), .CK(clk_p_i), .RB(n109), .Q(
        inst_r[0]) );
  QDFFRBN \inst_r_reg[1]  ( .D(inst_i[1]), .CK(clk_p_i), .RB(n109), .Q(
        inst_r[1]) );
  QDFFRBN \state_r_reg[0]  ( .D(n88), .CK(clk_p_i), .RB(n109), .Q(state_r[0])
         );
  QDFFRBN \state_r_reg[2]  ( .D(n89), .CK(clk_p_i), .RB(n109), .Q(state_r[2])
         );
  QDFFRBN \state_r_reg[1]  ( .D(n87), .CK(clk_p_i), .RB(n109), .Q(state_r[1])
         );
  QDFFRBN \inst_r_reg[2]  ( .D(inst_i[2]), .CK(clk_p_i), .RB(n109), .Q(
        inst_r[2]) );
  QDFFRBN \reg_data_a_reg[7]  ( .D(data_a_i[7]), .CK(clk_p_i), .RB(n110), .Q(
        data_a_w[7]) );
  QDFFRBN \reg_data_a_reg[6]  ( .D(data_a_i[6]), .CK(clk_p_i), .RB(n110), .Q(
        data_a_w[6]) );
  QDFFRBN \reg_data_a_reg[5]  ( .D(data_a_i[5]), .CK(clk_p_i), .RB(n110), .Q(
        data_a_w[5]) );
  QDFFRBN \reg_data_a_reg[4]  ( .D(data_a_i[4]), .CK(clk_p_i), .RB(n110), .Q(
        data_a_w[4]) );
  QDFFRBN \reg_data_a_reg[3]  ( .D(data_a_i[3]), .CK(clk_p_i), .RB(n110), .Q(
        data_a_w[3]) );
  QDFFRBN \reg_data_a_reg[2]  ( .D(data_a_i[2]), .CK(clk_p_i), .RB(n110), .Q(
        data_a_w[2]) );
  QDFFRBN \reg_data_a_reg[1]  ( .D(data_a_i[1]), .CK(clk_p_i), .RB(n115), .Q(
        data_a_w[1]) );
  QDFFRBN \reg_data_a_reg[0]  ( .D(data_a_i[0]), .CK(clk_p_i), .RB(n112), .Q(
        data_a_w[0]) );
  QDFFRBN \reg_data_b_reg[7]  ( .D(data_b_i[7]), .CK(clk_p_i), .RB(n112), .Q(
        data_b_w[7]) );
  QDFFRBN \reg_data_b_reg[6]  ( .D(data_b_i[6]), .CK(clk_p_i), .RB(n112), .Q(
        data_b_w[6]) );
  QDFFRBN \reg_data_b_reg[5]  ( .D(data_b_i[5]), .CK(clk_p_i), .RB(n113), .Q(
        data_b_w[5]) );
  QDFFRBN \reg_data_b_reg[4]  ( .D(data_b_i[4]), .CK(clk_p_i), .RB(reset_n_i), 
        .Q(data_b_w[4]) );
  QDFFRBN \reg_data_b_reg[3]  ( .D(data_b_i[3]), .CK(clk_p_i), .RB(n114), .Q(
        data_b_w[3]) );
  QDFFRBN \reg_data_b_reg[2]  ( .D(data_b_i[2]), .CK(clk_p_i), .RB(n114), .Q(
        data_b_w[2]) );
  QDFFRBN \reg_data_b_reg[1]  ( .D(data_b_i[1]), .CK(clk_p_i), .RB(n114), .Q(
        data_b_w[1]) );
  QDFFRBN \reg_data_b_reg[0]  ( .D(data_b_i[0]), .CK(clk_p_i), .RB(n114), .Q(
        data_b_w[0]) );
  MOAI1S U99 ( .A1(n47), .A2(n116), .B1(n116), .B2(n122), .O(n52) );
  OA12 U100 ( .B1(out_inst_1_15), .B2(n38), .A1(n47), .O(n90) );
  OR2 U101 ( .I1(n116), .I2(n38), .O(n91) );
  INV1S U102 ( .I(n36), .O(n92) );
  INV1S U103 ( .I(n36), .O(n93) );
  INV1S U104 ( .I(n52), .O(n94) );
  INV1S U105 ( .I(n94), .O(n95) );
  INV1S U106 ( .I(n90), .O(n96) );
  INV1S U107 ( .I(n90), .O(n97) );
  INV1S U108 ( .I(n91), .O(n98) );
  INV1S U109 ( .I(n91), .O(n99) );
  INV1S U110 ( .I(n39), .O(n100) );
  INV1S U111 ( .I(n39), .O(n101) );
  INV1S U112 ( .I(n48), .O(n102) );
  INV1S U113 ( .I(n48), .O(n103) );
  INV1S U114 ( .I(n41), .O(n104) );
  INV1S U115 ( .I(n41), .O(n105) );
  INV1S U116 ( .I(n41), .O(n106) );
  OR2T U117 ( .I1(n95), .I2(n108), .O(data_o[8]) );
  AO12T U118 ( .B1(out_inst_2[10]), .B2(n105), .A1(n52), .O(data_o[10]) );
  AO12T U119 ( .B1(out_inst_2[11]), .B2(n106), .A1(n95), .O(data_o[11]) );
  AO12T U120 ( .B1(out_inst_2[12]), .B2(n104), .A1(n52), .O(data_o[12]) );
  AO12T U121 ( .B1(out_inst_2[13]), .B2(n105), .A1(n95), .O(data_o[13]) );
  AO12T U122 ( .B1(out_inst_2[14]), .B2(n106), .A1(n52), .O(data_o[14]) );
  AO12T U123 ( .B1(out_inst_2[15]), .B2(n104), .A1(n95), .O(data_o[15]) );
  INV1S U124 ( .I(n122), .O(n107) );
  AO12T U125 ( .B1(out_inst_2[9]), .B2(n105), .A1(n52), .O(data_o[9]) );
  AO112T U126 ( .C1(out_inst_0[7]), .C2(n102), .A1(n54), .B1(n55), .O(
        data_o[7]) );
  AO222S U127 ( .A1(out_inst_1[7]), .A2(n97), .B1(N38), .B2(n99), .C1(n101), 
        .C2(n58), .O(n55) );
  OR3B2T U128 ( .I1(n59), .B1(n60), .B2(n61), .O(data_o[6]) );
  OR3B2T U129 ( .I1(n63), .B1(n64), .B2(n65), .O(data_o[5]) );
  OR3B2T U130 ( .I1(n67), .B1(n68), .B2(n69), .O(data_o[4]) );
  OR3B2T U131 ( .I1(n71), .B1(n72), .B2(n73), .O(data_o[3]) );
  OR3B2T U132 ( .I1(n75), .B1(n76), .B2(n77), .O(data_o[2]) );
  OR3B2T U133 ( .I1(n79), .B1(n80), .B2(n81), .O(data_o[1]) );
  OR3B2T U134 ( .I1(n83), .B1(n84), .B2(n85), .O(data_o[0]) );
  INV1S U135 ( .I(out_inst_1_15), .O(n116) );
  ND3 U136 ( .I1(n47), .I2(n48), .I3(n49), .O(n28) );
  AOI22S U137 ( .A1(n50), .A2(n43), .B1(n37), .B2(n121), .O(n49) );
  INV1S U138 ( .I(n38), .O(n121) );
  OAI222S U139 ( .A1(n40), .A2(n39), .B1(n51), .B2(n119), .C1(n118), .C2(n36), 
        .O(n50) );
  INV1S U140 ( .I(n42), .O(n122) );
  ND3 U141 ( .I1(n32), .I2(n33), .I3(n34), .O(n27) );
  AO13S U142 ( .B1(n36), .B2(n41), .B3(n42), .A1(n43), .O(n33) );
  AOI22S U143 ( .A1(n44), .A2(n119), .B1(n45), .B2(n122), .O(n32) );
  OA12 U144 ( .B1(n45), .B2(n42), .A1(n41), .O(n51) );
  OAI22S U145 ( .A1(n43), .A2(n48), .B1(n47), .B2(n43), .O(n25) );
  ND3 U146 ( .I1(n124), .I2(n120), .I3(n123), .O(n48) );
  INV1S U147 ( .I(n35), .O(n118) );
  INV1S U148 ( .I(n40), .O(n117) );
  AO22 U149 ( .A1(out_inst_2[8]), .A2(n104), .B1(out_inst_0[8]), .B2(n102), 
        .O(n108) );
  INV1S U150 ( .I(out_inst_1[7]), .O(N23) );
  INV1S U151 ( .I(out_inst_1[1]), .O(N29) );
  INV1S U152 ( .I(out_inst_1[2]), .O(N28) );
  INV1S U153 ( .I(out_inst_1[3]), .O(N27) );
  INV1S U154 ( .I(out_inst_1[4]), .O(N26) );
  INV1S U155 ( .I(out_inst_1[5]), .O(N25) );
  INV1S U156 ( .I(out_inst_1[6]), .O(N24) );
  BUF1CK U157 ( .I(n113), .O(n111) );
  BUF1CK U158 ( .I(reset_n_i), .O(n110) );
  BUF1CK U159 ( .I(n113), .O(n112) );
  ND3 U160 ( .I1(n123), .I2(n124), .I3(state_r[2]), .O(n42) );
  XNR2HS U161 ( .I1(inst_r[1]), .I2(inst_r[2]), .O(n35) );
  INV1S U162 ( .I(state_r[0]), .O(n123) );
  INV1S U163 ( .I(state_r[2]), .O(n120) );
  ND3 U164 ( .I1(n123), .I2(n120), .I3(state_r[1]), .O(n41) );
  INV1S U165 ( .I(state_r[1]), .O(n124) );
  OAI22S U166 ( .A1(n29), .A2(n123), .B1(n25), .B2(n30), .O(n88) );
  NR2 U167 ( .I1(n25), .I2(n27), .O(n29) );
  MOAI1S U168 ( .A1(n25), .A2(n26), .B1(n27), .B2(state_r[1]), .O(n87) );
  MOAI1S U169 ( .A1(n25), .A2(n31), .B1(n27), .B2(state_r[2]), .O(n89) );
  NR2 U170 ( .I1(n35), .I2(inst_r[2]), .O(n45) );
  ND3 U171 ( .I1(n124), .I2(n120), .I3(state_r[0]), .O(n47) );
  ND3 U172 ( .I1(state_r[2]), .I2(n123), .I3(state_r[1]), .O(n38) );
  ND3 U173 ( .I1(inst_r[1]), .I2(inst_r[0]), .I3(inst_r[2]), .O(n43) );
  ND3 U174 ( .I1(state_r[0]), .I2(n120), .I3(state_r[1]), .O(n36) );
  INV1S U175 ( .I(inst_r[0]), .O(n119) );
  ND3 U176 ( .I1(state_r[0]), .I2(n124), .I3(state_r[2]), .O(n39) );
  NR2 U177 ( .I1(n119), .I2(inst_r[1]), .O(n37) );
  OA12 U178 ( .B1(inst_r[2]), .B2(inst_r[0]), .A1(n46), .O(n40) );
  OR2 U179 ( .I1(inst_r[2]), .I2(inst_r[1]), .O(n46) );
  MAOI1 U180 ( .A1(n100), .A2(n86), .B1(n42), .B2(out_inst_1[0]), .O(n85) );
  AOI22S U181 ( .A1(N31), .A2(n98), .B1(out_inst_1[0]), .B2(n96), .O(n84) );
  MAOI1 U182 ( .A1(n101), .A2(n82), .B1(n42), .B2(out_inst_1[1]), .O(n81) );
  AOI22S U183 ( .A1(N32), .A2(n99), .B1(out_inst_1[1]), .B2(n97), .O(n80) );
  MAOI1 U184 ( .A1(n100), .A2(n78), .B1(n42), .B2(out_inst_1[2]), .O(n77) );
  AOI22S U185 ( .A1(N33), .A2(n98), .B1(out_inst_1[2]), .B2(n96), .O(n76) );
  MAOI1 U186 ( .A1(n101), .A2(n74), .B1(n107), .B2(out_inst_1[3]), .O(n73) );
  AOI22S U187 ( .A1(N34), .A2(n99), .B1(out_inst_1[3]), .B2(n97), .O(n72) );
  MAOI1 U188 ( .A1(n100), .A2(n70), .B1(n107), .B2(out_inst_1[4]), .O(n69) );
  AOI22S U189 ( .A1(N35), .A2(n98), .B1(out_inst_1[4]), .B2(n96), .O(n68) );
  MAOI1 U190 ( .A1(n101), .A2(n66), .B1(n107), .B2(out_inst_1[5]), .O(n65) );
  AOI22S U191 ( .A1(N36), .A2(n99), .B1(out_inst_1[5]), .B2(n97), .O(n64) );
  MAOI1 U192 ( .A1(n100), .A2(n62), .B1(n107), .B2(out_inst_1[6]), .O(n61) );
  AOI22S U193 ( .A1(N37), .A2(n98), .B1(out_inst_1[6]), .B2(n96), .O(n60) );
  MOAI1S U194 ( .A1(out_inst_1[7]), .A2(n107), .B1(out_inst_2[7]), .B2(n105), 
        .O(n54) );
  XOR2HS U195 ( .I1(out_inst_3[6]), .I2(data_b_r[7]), .O(n58) );
  XOR2HS U196 ( .I1(data_b_r[0]), .I2(\data_a_r[0] ), .O(n86) );
  XOR2HS U197 ( .I1(out_inst_3[0]), .I2(data_b_r[1]), .O(n82) );
  XOR2HS U198 ( .I1(out_inst_3[1]), .I2(data_b_r[2]), .O(n78) );
  XOR2HS U199 ( .I1(out_inst_3[2]), .I2(data_b_r[3]), .O(n74) );
  XOR2HS U200 ( .I1(out_inst_3[3]), .I2(data_b_r[4]), .O(n70) );
  XOR2HS U201 ( .I1(out_inst_3[4]), .I2(data_b_r[5]), .O(n66) );
  XOR2HS U202 ( .I1(out_inst_3[5]), .I2(data_b_r[6]), .O(n62) );
  BUF1CK U203 ( .I(n115), .O(n109) );
  BUF1CK U204 ( .I(reset_n_i), .O(n115) );
  BUF1CK U205 ( .I(reset_n_i), .O(n113) );
  BUF1CK U206 ( .I(reset_n_i), .O(n114) );
  TIE0 U207 ( .O(n2) );
  INV1S U208 ( .I(out_inst_1[0]), .O(N30) );
endmodule
module CHIP ( clk_p_i, reset_n_i, data_a_i, data_b_i, inst_i, data_o );
  input [7:0] data_a_i;
  input [7:0] data_b_i;
  input [2:0] inst_i;
  output [15:0] data_o;
  input clk_p_i, reset_n_i;

  
  
  wire [7:0] i_data_a_i;
  wire [7:0] i_data_b_i;
  wire [2:0] i_inst_i;
  wire [15:0] i_data_o;
  wire i_clk_p_i, i_reset_n_i;
  wire n_logic0,n_logic1;
  alu alu_in( .clk_p_i(i_clk_p_i), .reset_n_i(i_reset_n_i), .data_a_i(i_data_a_i), .data_b_i(i_data_b_i), .inst_i(i_inst_i), .data_o(i_data_o) );
  
  TIE0 ipad_n_logic0(.O(n_logic0));
  TIE1 ipad_n_logic1(.O(n_logic1));
  XMD ipad_clk_p_i (.O(i_clk_p_i), .I(clk_p_i), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_reset_n_i (.O(i_reset_n_i), .I(reset_n_i), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_inst_i_0  (.O(i_inst_i[0]), .I(inst_i[0]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_inst_i_1  (.O(i_inst_i[1]), .I(inst_i[1]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_inst_i_2  (.O(i_inst_i[2]), .I(inst_i[2]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_0 (.O(i_data_a_i[0]), .I(data_a_i[0]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_1 (.O(i_data_a_i[1]), .I(data_a_i[1]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_2 (.O(i_data_a_i[2]), .I(data_a_i[2]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_3 (.O(i_data_a_i[3]), .I(data_a_i[3]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_4 (.O(i_data_a_i[4]), .I(data_a_i[4]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_5 (.O(i_data_a_i[5]), .I(data_a_i[5]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_6 (.O(i_data_a_i[6]), .I(data_a_i[6]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_a_i_7 (.O(i_data_a_i[7]), .I(data_a_i[7]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_0 (.O(i_data_b_i[0]), .I(data_b_i[0]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_1 (.O(i_data_b_i[1]), .I(data_b_i[1]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_2 (.O(i_data_b_i[2]), .I(data_b_i[2]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_3 (.O(i_data_b_i[3]), .I(data_b_i[3]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_4 (.O(i_data_b_i[4]), .I(data_b_i[4]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_5 (.O(i_data_b_i[5]), .I(data_b_i[5]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_6 (.O(i_data_b_i[6]), .I(data_b_i[6]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_data_b_i_7 (.O(i_data_b_i[7]), .I(data_b_i[7]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  
  
  YA2GSD ipad_data_o_0 (.O(data_o[0]), .I(i_data_o[0]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_1 (.O(data_o[1]), .I(i_data_o[1]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_2 (.O(data_o[2]), .I(i_data_o[2]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_3 (.O(data_o[3]), .I(i_data_o[3]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_4 (.O(data_o[4]), .I(i_data_o[4]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_5 (.O(data_o[5]), .I(i_data_o[5]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_6 (.O(data_o[6]), .I(i_data_o[6]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_7 (.O(data_o[7]), .I(i_data_o[7]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_8 (.O(data_o[8]), .I(i_data_o[8]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_9 (.O(data_o[9]), .I(i_data_o[9]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_10 (.O(data_o[10]), .I(i_data_o[10]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_11 (.O(data_o[11]), .I(i_data_o[11]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_12 (.O(data_o[12]), .I(i_data_o[12]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_13 (.O(data_o[13]), .I(i_data_o[13]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_14 (.O(data_o[14]), .I(i_data_o[14]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_data_o_15 (.O(data_o[15]), .I(i_data_o[15]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  
  
endmodule