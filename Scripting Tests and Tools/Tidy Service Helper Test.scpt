FasdUAS 1.101.10   ��   ��    k             l     ��  ��    ) #	Balthisar Tidy Service Helper Test     � 	 	 F 	 B a l t h i s a r   T i d y   S e r v i c e   H e l p e r   T e s t   
  
 l     ��������  ��  ��        l     ��  ��    C =	This script uses Balthisar Tidy Service Helper's AppleScript     �   z 	 T h i s   s c r i p t   u s e s   B a l t h i s a r   T i d y   S e r v i c e   H e l p e r ' s   A p p l e S c r i p t      l     ��  ��    8 2	library in order to test its basic functionality.     �   d 	 l i b r a r y   i n   o r d e r   t o   t e s t   i t s   b a s i c   f u n c t i o n a l i t y .      l     ��������  ��  ��        l     ��  ��     	Created by: Jim Derry     �   , 	 C r e a t e d   b y :   J i m   D e r r y      l     ��   ��    $ 	Created on: 11/17/15 15:50:11      � ! ! < 	 C r e a t e d   o n :   1 1 / 1 7 / 1 5   1 5 : 5 0 : 1 1   " # " l     ��������  ��  ��   #  $ % $ l     �� & '��   & ( "	Copyright (C) 2014-2015 Jim Derry    ' � ( ( D 	 C o p y r i g h t   ( C )   2 0 1 4 - 2 0 1 5   J i m   D e r r y %  ) * ) l     �� + ,��   +  	All Rights Reserved    , � - - ( 	 A l l   R i g h t s   R e s e r v e d *  . / . l     ��������  ��  ��   /  0 1 0 l     ��������  ��  ��   1  2 3 2 l     ��������  ��  ��   3  4 5 4 l     �� 6 7��   6 D >--------------------------------------------------------------    7 � 8 8 | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 5  9 : 9 l     �� ; <��   ; 
 	run    < � = =  	 r u n :  > ? > l     �� @ A��   @ D >--------------------------------------------------------------    A � B B | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ?  C D C i      E F E I     ������
�� .aevtoappnull  �   � ****��  ��   F k     � G G  H I H l     ��������  ��  ��   I  J K J r      L M L I    �� N��
�� .sysontocTEXT       shor N m     ���� 	��   M o      ���� 0 ht HT K  O P O r     Q R Q I   �� S��
�� .sysontocTEXT       shor S m    	���� 
��   R o      ���� 0 lf LF P  T U T l   ��������  ��  ��   U  V W V r     X Y X m     Z Z � [ [ , < h 1 > H e l l o ,   w o r l d . < / h 2 > Y o      ���� 0 	dirtytext 	dirtyText W  \ ] \ l   ��������  ��  ��   ]  ^ _ ^ r     ` a ` b     b c b b     d e d m     f f � g g h T h i s   s i m p l e   t e s t   w i l l   T i d y   t h e   f o l l o w i n g   ( b a d )   t e x t : e o    ���� 0 lf LF c o    ���� 0 lf LF a o      ���� 0 srcmsg srcMsg _  h i h r    ' j k j b    % l m l b    # n o n b    ! p q p b     r s r o    ���� 0 srcmsg srcMsg s o    ���� 0 ht HT q o     ���� 0 	dirtytext 	dirtyText o o   ! "���� 0 lf LF m o   # $���� 0 lf LF k o      ���� 0 srcmsg srcMsg i  t u t r   ( 1 v w v b   ( / x y x b   ( - z { z b   ( + | } | o   ( )���� 0 srcmsg srcMsg } m   ) * ~ ~ �   r Y o u   w i l l   t h e n   s e e   t h r e e   m e s s a g e   b o x e s   w i t h   ( r e s p e c t i v e l y ) { o   + ,���� 0 lf LF y o   - .���� 0 lf LF w o      ���� 0 srcmsg srcMsg u  � � � r   2 ; � � � b   2 9 � � � b   2 7 � � � b   2 5 � � � o   2 3���� 0 srcmsg srcMsg � o   3 4���� 0 ht HT � m   5 6 � � � � � ( "   T h e   o r i g i n a l   t e x t . � o   7 8���� 0 lf LF � o      ���� 0 srcmsg srcMsg �  � � � r   < E � � � b   < C � � � b   < A � � � b   < ? � � � o   < =���� 0 srcmsg srcMsg � o   = >���� 0 ht HT � m   ? @ � � � � � L "   T h e   T i d y ' d   t e x t   ( c o m p l e t e   d o c u m e n t ) . � o   A B���� 0 lf LF � o      ���� 0 srcmsg srcMsg �  � � � r   F O � � � b   F M � � � b   F K � � � b   F I � � � o   F G���� 0 srcmsg srcMsg � o   G H���� 0 ht HT � m   I J � � � � � X "   T h e   T i d y ' d   t e x t   ( t h e   < b o d y >   c o n t e n t   o n l y ) . � o   K L���� 0 lf LF � o      ���� 0 srcmsg srcMsg �  � � � l  P P��������  ��  ��   �  � � � I   P W�� ����� 0 okdialog okDialog �  � � � o   Q R���� 0 srcmsg srcMsg �  ��� � m   R S � � � � �  W e l c o m e��  ��   �  � � � l  X X��������  ��  ��   �  � � � O   X � � � � k   \ � � �  � � � r   \ c � � � o   \ ]���� 0 	dirtytext 	dirtyText � 1   ] b��
�� 
Bsrc �  � � � n  d q � � � I   e q�� ����� 0 okdialog okDialog �  � � � 1   e j��
�� 
Bsrc �  ��� � m   j m � � � � �  S o u r c e   T e x t��  ��   �  f   d e �  � � � n  r  � � � I   s �� ����� 0 okdialog okDialog �  � � � 1   s x��
�� 
Btdd �  ��� � m   x { � � � � �  T i d y   T e x t��  ��   �  f   r s �  � � � n  � � � � � I   � ��� ����� 0 okdialog okDialog �  � � � 1   � ���
�� 
Btdb �  ��� � m   � � � � � � �  T i d y   B o d y   O n l y��  ��   �  f   � � �  ��� � I  � �������
�� .aevtquitnull��� ��� null��  ��  ��   � m   X Y � �R                                                                                      @ alis    �  	Macintosh                  �v��H+   ��Balthisar Tidy Servi#F10BC7.app                                 ���q7        ����  	                PlugIns     �v!      �p��    4 �� �� �� �> j�Y jǨ j�! .�� 	� 	� &] %� dC  �Macintosh:Users: jderry: Library: Developer: Xcode: DerivedData: Balthisar_Tidy-bvpybresy#6AC721: Build: Products: Debug: Balthisar Tidy for Work.app: Contents: PlugIns: Balthisar Tidy Servi#F10BC7.app   D ! B a l t h i s a r   T i d y   S e r v i c e   H e l p e r . a p p   	 M a c i n t o s h  �Users/jderry/Library/Developer/Xcode/DerivedData/Balthisar_Tidy-bvpybresykcplwanwodqvzveuuyl/Build/Products/Debug/Balthisar Tidy for Work.app/Contents/PlugIns/Balthisar Tidy Service Helper.app  /    ��   �  ��� � l  � ���������  ��  ��  ��   D  � � � l     ��������  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � D >--------------------------------------------------------------    � � � � | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - �  � � � l     �� � ���   �  		okDialog    � � � �  	 o k D i a l o g �  � � � l     �� � ���   � D >--------------------------------------------------------------    � � � � | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - �  � � � i     � � � I      �� ����� 0 okdialog okDialog �  � � � o      ���� 0 
themessage 
theMessage �  ��� � o      ���� 	0 title  ��  ��   � k      � �  � � � l     ��������  ��  ��   �  � � � L      � � I    �� � �
�� .sysodlogaskr        TEXT � l     ����� � c      � � � o     ���� 0 
themessage 
theMessage � m    �
� 
ctxt��  ��   � �~ 
�~ 
btns  J     �} m     �  O K�}   �|
�| 
dflt m    	 �		  O K �{
�z
�{ 
appr
 o   
 �y�y 	0 title  �z   � �x l   �w�v�u�w  �v  �u  �x   �  l     �t�s�r�t  �s  �r    l     �q�p�o�q  �p  �o   �n l     �m�l�k�m  �l  �k  �n       �j�j   �i�h
�i .aevtoappnull  �   � ****�h 0 okdialog okDialog �g F�f�e�d
�g .aevtoappnull  �   � ****�f  �e     �c�b�a�`�_ Z�^ f�] ~ � � � ��\ ��[ ��Z ��Y ��X�c 	
�b .sysontocTEXT       shor�a 0 ht HT�` 
�_ 0 lf LF�^ 0 	dirtytext 	dirtyText�] 0 srcmsg srcMsg�\ 0 okdialog okDialog
�[ 
Bsrc
�Z 
Btdd
�Y 
Btdb
�X .aevtquitnull��� ��� null�d ��j E�O�j E�O�E�O��%�%E�O��%�%�%�%E�O��%�%�%E�O��%�%�%E�O��%�%�%E�O��%�%�%E�O*��l+ O� 9�*a ,FO)*a ,a l+ O)*a ,a l+ O)*a ,a l+ O*j UOP �W ��V�U�T�W 0 okdialog okDialog�V �S�S   �R�Q�R 0 
themessage 
theMessage�Q 	0 title  �U   �P�O�P 0 
themessage 
theMessage�O 	0 title   �N�M�L�K�J�I
�N 
ctxt
�M 
btns
�L 
dflt
�K 
appr�J 
�I .sysodlogaskr        TEXT�T ��&��kv���� OP ascr  ��ޭ