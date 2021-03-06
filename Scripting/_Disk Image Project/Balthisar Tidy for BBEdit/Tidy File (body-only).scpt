FasdUAS 1.101.10   ��   ��    k             l     ��  ��     	Tidy File (body-only)     � 	 	 , 	 T i d y   F i l e   ( b o d y - o n l y )   
  
 l     ��������  ��  ��        l     ��  ��    L F	This script works with BBEdit and Balthisar Tidy for Work in order to     �   � 	 T h i s   s c r i p t   w o r k s   w i t h   B B E d i t   a n d   B a l t h i s a r   T i d y   f o r   W o r k   i n   o r d e r   t o      l     ��  ��    ) #	implement HTML Tidy within BBEdit.     �   F 	 i m p l e m e n t   H T M L   T i d y   w i t h i n   B B E d i t .      l     ��������  ��  ��        l     ��  ��    N H	This script will Tidy the entire BBEdit document and return the portion     �   � 	 T h i s   s c r i p t   w i l l   T i d y   t h e   e n t i r e   B B E d i t   d o c u m e n t   a n d   r e t u r n   t h e   p o r t i o n      l     ��   ��    G A	of an HTML document within the <body> tags, omitting the <head>.      � ! ! � 	 o f   a n   H T M L   d o c u m e n t   w i t h i n   t h e   < b o d y >   t a g s ,   o m i t t i n g   t h e   < h e a d > .   " # " l     ��������  ��  ��   #  $ % $ l     �� & '��   & P J	To use it, simply select "Tidy File (body-only)" in BBEdit's Script menu.    ' � ( ( � 	 T o   u s e   i t ,   s i m p l y   s e l e c t   " T i d y   F i l e   ( b o d y - o n l y ) "   i n   B B E d i t ' s   S c r i p t   m e n u . %  ) * ) l     ��������  ��  ��   *  + , + l     �� - .��   - H B	To install this script into BBEdit, copy or move it into BBEdit's    . � / / � 	 T o   i n s t a l l   t h i s   s c r i p t   i n t o   B B E d i t ,   c o p y   o r   m o v e   i t   i n t o   B B E d i t ' s ,  0 1 0 l     �� 2 3��   2 H B	Scripts folder, which is handily available from its scripts menu.    3 � 4 4 � 	 S c r i p t s   f o l d e r ,   w h i c h   i s   h a n d i l y   a v a i l a b l e   f r o m   i t s   s c r i p t s   m e n u . 1  5 6 5 l     ��������  ��  ��   6  7 8 7 l     �� 9 :��   9 I C	Note also that Balthisar Tidy for Work also offers System Services    : � ; ; � 	 N o t e   a l s o   t h a t   B a l t h i s a r   T i d y   f o r   W o r k   a l s o   o f f e r s   S y s t e m   S e r v i c e s 8  < = < l     �� > ?��   > ) #	that work perfectly within BBEdit.    ? � @ @ F 	 t h a t   w o r k   p e r f e c t l y   w i t h i n   B B E d i t . =  A B A l     ��������  ��  ��   B  C D C l     �� E F��   E  	Created by: Jim Derry    F � G G , 	 C r e a t e d   b y :   J i m   D e r r y D  H I H l     �� J K��   J $ 	Created on: 04/12/14 13:41:11    K � L L < 	 C r e a t e d   o n :   0 4 / 1 2 / 1 4   1 3 : 4 1 : 1 1 I  M N M l     ��������  ��  ��   N  O P O l     �� Q R��   Q ( "	Copyright (C) 2014-2015 Jim Derry    R � S S D 	 C o p y r i g h t   ( C )   2 0 1 4 - 2 0 1 5   J i m   D e r r y P  T U T l     �� V W��   V  	All Rights Reserved    W � X X ( 	 A l l   R i g h t s   R e s e r v e d U  Y Z Y l     ��������  ��  ��   Z  [ \ [ l     ��������  ��  ��   \  ] ^ ] l      _���� _ q       ` ` ������ 0 original_text  ��  ��  ��   ^  a b a l      c���� c q       d d ������ 0 new_text  ��  ��  ��   b  e f e l     ��������  ��  ��   f  g h g l     i���� i O      j k j r     l m l l   
 n���� n n    
 o p o 1    
��
�� 
pcnt p 4    �� q
�� 
TxtW q m    ���� ��  ��   m o      ���� 0 original_text   k m      r r�                                                                                  R*ch  alis    r  BigMac                     �\��H+   �
BBEdit.app                                                     ɋ�.`;        ����  	                Productivity    �\Ag      �-�     � ��k  7BigMac:Applications: _Non-OEM: Productivity: BBEdit.app    
 B B E d i t . a p p    B i g M a c  -Applications/_Non-OEM/Productivity/BBEdit.app   / ��  ��  ��   h  s t s l     ��������  ��  ��   t  u v u l     ��������  ��  ��   v  w x w l    y���� y O     z { z k     | |  } ~ } r      �  o    ���� 0 original_text   � 1    ��
�� 
Bsrc ~  ��� � r     � � � 1    ��
�� 
Btdb � o      ���� 0 new_text  ��   { m     � �H                                                                                      @ alis    �  BigMac                     �\��H+  mS�Balthisar Tidy Serv#26FD5CC.app                                o���q(�        ����  	                PlugIns     �\Ag      �p�^    4mS�mS�mS�7B�7B5R�5R� <; l� l� 	Cz 	Cu ��  �BigMac:Users: jderry: Library: Developer: Xcode: DerivedData: Balthisar_Tidy-bvpybres#23552B1: Build: Products: Debug: Balthisar Tidy for Work.app: Contents: PlugIns: Balthisar Tidy Serv#26FD5CC.app  D ! B a l t h i s a r   T i d y   S e r v i c e   H e l p e r . a p p    B i g M a c  �Users/jderry/Library/Developer/Xcode/DerivedData/Balthisar_Tidy-bvpybresykcplwanwodqvzveuuyl/Build/Products/Debug/Balthisar Tidy for Work.app/Contents/PlugIns/Balthisar Tidy Service Helper.app  /    ��  ��  ��   x  � � � l     ��������  ��  ��   �  � � � l   , ����� � O    , � � � r   # + � � � o   # $���� 0 new_text   � l      ����� � n       � � � 1   ( *��
�� 
pcnt � 4   $ (�� �
�� 
TxtW � m   & '���� ��  ��   � m      � ��                                                                                  R*ch  alis    r  BigMac                     �\��H+   �
BBEdit.app                                                     ɋ�.`;        ����  	                Productivity    �\Ag      �-�     � ��k  7BigMac:Applications: _Non-OEM: Productivity: BBEdit.app    
 B B E d i t . a p p    B i g M a c  -Applications/_Non-OEM/Productivity/BBEdit.app   / ��  ��  ��   �  ��� � l     ��������  ��  ��  ��       �� � ���   � ��
�� .aevtoappnull  �   � **** � �� ����� � ���
�� .aevtoappnull  �   � **** � k     , � �  ] � �  a � �  g � �  w � �  �����  ��  ��   � ������ 0 original_text  �� 0 new_text   �  r���� �����
�� 
TxtW
�� 
pcnt
�� 
Bsrc
�� 
Btdb�� -� 
*�k/�,E�UO� �*�,FO*�,E�UO� 
�*�k/�,FU ascr  ��ޭ