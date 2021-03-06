FasdUAS 1.101.10   ��   ��    k             l     ��  ��    ! 	Tidy Selection (body-only)     � 	 	 6 	 T i d y   S e l e c t i o n   ( b o d y - o n l y )   
  
 l     ��������  ��  ��        l     ��  ��    L F	This script works with BBEdit and Balthisar Tidy for Work in order to     �   � 	 T h i s   s c r i p t   w o r k s   w i t h   B B E d i t   a n d   B a l t h i s a r   T i d y   f o r   W o r k   i n   o r d e r   t o      l     ��  ��    ) #	implement HTML Tidy within BBEdit.     �   F 	 i m p l e m e n t   H T M L   T i d y   w i t h i n   B B E d i t .      l     ��������  ��  ��        l     ��  ��    M G	This script will Tidy the selected portion of your BBEdit document and     �   � 	 T h i s   s c r i p t   w i l l   T i d y   t h e   s e l e c t e d   p o r t i o n   o f   y o u r   B B E d i t   d o c u m e n t   a n d      l     ��   ��    E ?	return the portion of an HTML document within the <body> tags,      � ! ! ~ 	 r e t u r n   t h e   p o r t i o n   o f   a n   H T M L   d o c u m e n t   w i t h i n   t h e   < b o d y >   t a g s ,   " # " l     �� $ %��   $  	omitting the <head>.    % � & & * 	 o m i t t i n g   t h e   < h e a d > . #  ' ( ' l     ��������  ��  ��   (  ) * ) l     �� + ,��   + U O	To use it, simply select "Tidy Selection (body-only)" in BBEdit's Script menu.    , � - - � 	 T o   u s e   i t ,   s i m p l y   s e l e c t   " T i d y   S e l e c t i o n   ( b o d y - o n l y ) "   i n   B B E d i t ' s   S c r i p t   m e n u . *  . / . l     ��������  ��  ��   /  0 1 0 l     �� 2 3��   2 H B	To install this script into BBEdit, copy or move it into BBEdit's    3 � 4 4 � 	 T o   i n s t a l l   t h i s   s c r i p t   i n t o   B B E d i t ,   c o p y   o r   m o v e   i t   i n t o   B B E d i t ' s 1  5 6 5 l     �� 7 8��   7 H B	Scripts folder, which is handily available from its scripts menu.    8 � 9 9 � 	 S c r i p t s   f o l d e r ,   w h i c h   i s   h a n d i l y   a v a i l a b l e   f r o m   i t s   s c r i p t s   m e n u . 6  : ; : l     ��������  ��  ��   ;  < = < l     �� > ?��   > I C	Note also that Balthisar Tidy for Work also offers System Services    ? � @ @ � 	 N o t e   a l s o   t h a t   B a l t h i s a r   T i d y   f o r   W o r k   a l s o   o f f e r s   S y s t e m   S e r v i c e s =  A B A l     �� C D��   C ) #	that work perfectly within BBEdit.    D � E E F 	 t h a t   w o r k   p e r f e c t l y   w i t h i n   B B E d i t . B  F G F l     ��������  ��  ��   G  H I H l     �� J K��   J  	Created by: Jim Derry    K � L L , 	 C r e a t e d   b y :   J i m   D e r r y I  M N M l     �� O P��   O $ 	Created on: 04/12/14 13:41:11    P � Q Q < 	 C r e a t e d   o n :   0 4 / 1 2 / 1 4   1 3 : 4 1 : 1 1 N  R S R l     ��������  ��  ��   S  T U T l     �� V W��   V ( "	Copyright (C) 2014-2015 Jim Derry    W � X X D 	 C o p y r i g h t   ( C )   2 0 1 4 - 2 0 1 5   J i m   D e r r y U  Y Z Y l     �� [ \��   [  	All Rights Reserved    \ � ] ] ( 	 A l l   R i g h t s   R e s e r v e d Z  ^ _ ^ l     ��������  ��  ��   _  ` a ` l     ��������  ��  ��   a  b c b l      d���� d q       e e ������ 0 original_text  ��  ��  ��   c  f g f l      h���� h q       i i ������ 0 new_text  ��  ��  ��   g  j k j l     ��������  ��  ��   k  l m l l     n���� n O      o p o r     q r q l    s���� s n     t u t 1   
 ��
�� 
pcnt u n    
 v w v 1    
��
�� 
pusl w 4    �� x
�� 
TxtW x m    ���� ��  ��   r o      ���� 0 original_text   p m      y y�                                                                                  R*ch  alis    r  BigMac                     �\��H+   �
BBEdit.app                                                     ɋ�.`;        ����  	                Productivity    �\Ag      �-�     � ��k  7BigMac:Applications: _Non-OEM: Productivity: BBEdit.app    
 B B E d i t . a p p    B i g M a c  -Applications/_Non-OEM/Productivity/BBEdit.app   / ��  ��  ��   m  z { z l     ��������  ��  ��   {  | } | l     ~���� ~ O       �  k     � �  � � � r     � � � o    ���� 0 original_text   � 1    ��
�� 
Bsrc �  ��� � r     � � � 1    ��
�� 
Btdb � o      ���� 0 new_text  ��   � m     � �H                                                                                      @ alis    �  BigMac                     �\��H+  mS�Balthisar Tidy Serv#26FD5CC.app                                o���q(�        ����  	                PlugIns     �\Ag      �p�^    4mS�mS�mS�7B�7B5R�5R� <; l� l� 	Cz 	Cu ��  �BigMac:Users: jderry: Library: Developer: Xcode: DerivedData: Balthisar_Tidy-bvpybres#23552B1: Build: Products: Debug: Balthisar Tidy for Work.app: Contents: PlugIns: Balthisar Tidy Serv#26FD5CC.app  D ! B a l t h i s a r   T i d y   S e r v i c e   H e l p e r . a p p    B i g M a c  �Users/jderry/Library/Developer/Xcode/DerivedData/Balthisar_Tidy-bvpybresykcplwanwodqvzveuuyl/Build/Products/Debug/Balthisar Tidy for Work.app/Contents/PlugIns/Balthisar Tidy Service Helper.app  /    ��  ��  ��   }  � � � l     ��������  ��  ��   �  � � � l  ! 0 ����� � O   ! 0 � � � r   % / � � � o   % &���� 0 new_text   � l      ����� � n       � � � 1   , .��
�� 
pcnt � l  & , ����� � n   & , � � � 1   * ,��
�� 
pusl � 4   & *�� �
�� 
TxtW � m   ( )���� ��  ��  ��  ��   � m   ! " � ��                                                                                  R*ch  alis    r  BigMac                     �\��H+   �
BBEdit.app                                                     ɋ�.`;        ����  	                Productivity    �\Ag      �-�     � ��k  7BigMac:Applications: _Non-OEM: Productivity: BBEdit.app    
 B B E d i t . a p p    B i g M a c  -Applications/_Non-OEM/Productivity/BBEdit.app   / ��  ��  ��   �  ��� � l     ��������  ��  ��  ��       �� � ���   � ��
�� .aevtoappnull  �   � **** � �� ����� � ���
�� .aevtoappnull  �   � **** � k     0 � �  b � �  f � �  l � �  | � �  �����  ��  ��   � ������ 0 original_text  �� 0 new_text   �  y������ �����
�� 
TxtW
�� 
pusl
�� 
pcnt
�� 
Bsrc
�� 
Btdb�� 1� *�k/�,�,E�UO� �*�,FO*�,E�UO� �*�k/�,�,FU ascr  ��ޭ