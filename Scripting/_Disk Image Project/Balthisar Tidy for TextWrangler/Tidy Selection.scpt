FasdUAS 1.101.10   ��   ��    k             l     ��  ��     	Tidy Selection     � 	 	  	 T i d y   S e l e c t i o n   
  
 l     ��������  ��  ��        l     ��  ��    R L	This script works with TextWrangler and Balthisar Tidy for Work in order to     �   � 	 T h i s   s c r i p t   w o r k s   w i t h   T e x t W r a n g l e r   a n d   B a l t h i s a r   T i d y   f o r   W o r k   i n   o r d e r   t o      l     ��  ��    / )	implement HTML Tidy within TextWrangler.     �   R 	 i m p l e m e n t   H T M L   T i d y   w i t h i n   T e x t W r a n g l e r .      l     ��������  ��  ��        l     ��  ��    S M	This script will Tidy the selected portion of your TextWrangler document and     �   � 	 T h i s   s c r i p t   w i l l   T i d y   t h e   s e l e c t e d   p o r t i o n   o f   y o u r   T e x t W r a n g l e r   d o c u m e n t   a n d      l     ��   ��    ' !	return a complete HTML document.      � ! ! B 	 r e t u r n   a   c o m p l e t e   H T M L   d o c u m e n t .   " # " l     ��������  ��  ��   #  $ % $ l     �� & '��   & O I	To use it, simply select "Tidy Selection" in TextWrangler's Script menu.    ' � ( ( � 	 T o   u s e   i t ,   s i m p l y   s e l e c t   " T i d y   S e l e c t i o n "   i n   T e x t W r a n g l e r ' s   S c r i p t   m e n u . %  ) * ) l     ��������  ��  ��   *  + , + l     �� - .��   - T N	To install this script into TextWrangler, copy or move it into TextWrangler's    . � / / � 	 T o   i n s t a l l   t h i s   s c r i p t   i n t o   T e x t W r a n g l e r ,   c o p y   o r   m o v e   i t   i n t o   T e x t W r a n g l e r ' s ,  0 1 0 l     �� 2 3��   2 H B	Scripts folder, which is handily available from its scripts menu.    3 � 4 4 � 	 S c r i p t s   f o l d e r ,   w h i c h   i s   h a n d i l y   a v a i l a b l e   f r o m   i t s   s c r i p t s   m e n u . 1  5 6 5 l     ��������  ��  ��   6  7 8 7 l     �� 9 :��   9 I C	Note also that Balthisar Tidy for Work also offers System Services    : � ; ; � 	 N o t e   a l s o   t h a t   B a l t h i s a r   T i d y   f o r   W o r k   a l s o   o f f e r s   S y s t e m   S e r v i c e s 8  < = < l     �� > ?��   > / )	that work perfectly within TextWrangler.    ? � @ @ R 	 t h a t   w o r k   p e r f e c t l y   w i t h i n   T e x t W r a n g l e r . =  A B A l     ��������  ��  ��   B  C D C l     �� E F��   E  	Created by: Jim Derry    F � G G , 	 C r e a t e d   b y :   J i m   D e r r y D  H I H l     �� J K��   J $ 	Created on: 04/12/14 13:41:11    K � L L < 	 C r e a t e d   o n :   0 4 / 1 2 / 1 4   1 3 : 4 1 : 1 1 I  M N M l     ��������  ��  ��   N  O P O l     �� Q R��   Q ( "	Copyright (C) 2014-2015 Jim Derry    R � S S D 	 C o p y r i g h t   ( C )   2 0 1 4 - 2 0 1 5   J i m   D e r r y P  T U T l     �� V W��   V  	All Rights Reserved    W � X X ( 	 A l l   R i g h t s   R e s e r v e d U  Y Z Y l     ��������  ��  ��   Z  [ \ [ l     ��������  ��  ��   \  ] ^ ] l      _���� _ q       ` ` ������ 0 original_text  ��  ��  ��   ^  a b a l      c���� c q       d d ������ 0 new_text  ��  ��  ��   b  e f e l     ��������  ��  ��   f  g h g l     i���� i O      j k j r     l m l l    n���� n n     o p o 1   
 ��
�� 
pcnt p n    
 q r q 1    
��
�� 
pusl r 4    �� s
�� 
TxtW s m    ���� ��  ��   m o      ���� 0 original_text   k m      t t�                                                                                  !Rch  alis    �  BigMac                     �\��H+   �TextWrangler.app                                               p���i��        ����  	                Productivity    �\Ag      �i     � ��k  =BigMac:Applications: _Non-OEM: Productivity: TextWrangler.app   "  T e x t W r a n g l e r . a p p    B i g M a c  3Applications/_Non-OEM/Productivity/TextWrangler.app   / ��  ��  ��   h  u v u l     ��������  ��  ��   v  w x w l     y���� y O      z { z k     | |  } ~ } r      �  o    ���� 0 original_text   � 1    ��
�� 
Bsrc ~  ��� � r     � � � 1    ��
�� 
Btdd � o      ���� 0 new_text  ��   { m     � �H                                                                                      @ alis    �  BigMac                     �\��H+  mS�Balthisar Tidy Serv#26FD5CC.app                                o���q(�        ����  	                PlugIns     �\Ag      �p�^    4mS�mS�mS�7B�7B5R�5R� <; l� l� 	Cz 	Cu ��  �BigMac:Users: jderry: Library: Developer: Xcode: DerivedData: Balthisar_Tidy-bvpybres#23552B1: Build: Products: Debug: Balthisar Tidy for Work.app: Contents: PlugIns: Balthisar Tidy Serv#26FD5CC.app  D ! B a l t h i s a r   T i d y   S e r v i c e   H e l p e r . a p p    B i g M a c  �Users/jderry/Library/Developer/Xcode/DerivedData/Balthisar_Tidy-bvpybresykcplwanwodqvzveuuyl/Build/Products/Debug/Balthisar Tidy for Work.app/Contents/PlugIns/Balthisar Tidy Service Helper.app  /    ��  ��  ��   x  � � � l     ��������  ��  ��   �  � � � l  ! 0 ����� � O   ! 0 � � � r   % / � � � o   % &���� 0 new_text   � l      ����� � n       � � � 1   , .��
�� 
pcnt � l  & , ����� � n   & , � � � 1   * ,��
�� 
pusl � 4   & *�� �
�� 
TxtW � m   ( )���� ��  ��  ��  ��   � m   ! " � ��                                                                                  !Rch  alis    �  BigMac                     �\��H+   �TextWrangler.app                                               p���i��        ����  	                Productivity    �\Ag      �i     � ��k  =BigMac:Applications: _Non-OEM: Productivity: TextWrangler.app   "  T e x t W r a n g l e r . a p p    B i g M a c  3Applications/_Non-OEM/Productivity/TextWrangler.app   / ��  ��  ��   �  ��� � l     ��������  ��  ��  ��       �� � ���   � ��
�� .aevtoappnull  �   � **** � �� ����� � ���
�� .aevtoappnull  �   � **** � k     0 � �  ] � �  a � �  g � �  w � �  �����  ��  ��   � ������ 0 original_text  �� 0 new_text   �  t������ �����
�� 
TxtW
�� 
pusl
�� 
pcnt
�� 
Bsrc
�� 
Btdd�� 1� *�k/�,�,E�UO� �*�,FO*�,E�UO� �*�k/�,�,FUascr  ��ޭ