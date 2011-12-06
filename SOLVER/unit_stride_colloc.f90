!========================
 module unit_stride_colloc
!========================
!
! Generic routines for the essential number crunching necessary for the time 
! loop and stiffness term, using unit-stride cache access, i.e. rearranging 
! any input array into a 1-D array and doing arithmetic operations upon that 
! 1-D loop. Most routines are specific to their single calling sequence 
! and contain various multiplicative factors of two, minus signs etc...
! Note that this module does not use any globally known quantities
! other than global_parameters (and is therefore transferable).
!
! :::::::::: CODE OPTIMIZATION ::::::::::::
! If any further runtime CPU & cache usage optimization is necessary, it is 
! most likely within this module and unrolled_loops as the calling modules 
! (basically time_evol_wave and stiffness) are for the most part just wrappers 
! to these routines (except for the global-to-elemental array copying in 
! stiffness which may be optimized differently).

use global_parameters

implicit none
public
contains

!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
! UNIT STRIDE ACCESS ROUTINES USED FOR TIME LOOP
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

!--------------------------------------------------------------------------
subroutine ustride_neg_colloc(stiff_acc,inv_mass,n)

integer, intent(in) :: n
real(kind=realkind), intent(inout) :: stiff_acc(1:n)
real(kind=realkind), intent(in) :: inv_mass(1:n)
integer :: i
                                                                    
  do i = 1, n
    stiff_acc(i) =  - stiff_acc(i) * inv_mass(i)
  end do 

end subroutine ustride_neg_colloc
!==========================================================================

!--------------------------------------------------------------------------
subroutine ustride_neg_2colloc(stiff_acc,inv_mass,n)

integer, intent(in) :: n
real(kind=realkind), intent(inout) :: stiff_acc(1:n)
real(kind=realkind), intent(in) :: inv_mass(1:n)
integer :: i
                                                                    
  do i = 1, n
    stiff_acc(i) =  - two * stiff_acc(i) * inv_mass(i)
  end do 

end subroutine ustride_neg_2colloc
!==========================================================================

!-------------------------------------------------------------------------
subroutine ustride_2sum(u,du,kappadt,n)

integer, intent(in) :: n
real(kind=realkind), intent(inout) :: u(1:n)
real(kind=realkind), intent(in)    :: du(1:n)
double precision, intent(in)       :: kappadt
integer :: i
                                                                    
  do i = 1, n
    u(i) = u(i) + kappadt*du(i)
  end do 

end subroutine ustride_2sum
!==========================================================================

!-------------------------------------------------------------------------
subroutine ustride_3sum(u,dt,du,halfdtsq,ddu,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: u(1:n)
real(kind=realkind), intent(in) :: du(1:n),ddu(1:n)
double precision, intent(in) :: dt,halfdtsq
integer :: i
                                                                    
  do i = 1, n
    u(i) = u(i) + dt*du(i) + halfdtsq*ddu(i)
  end do 

end subroutine ustride_3sum
!==========================================================================

!-------------------------------------------------------------------------
subroutine ustride_sum_neg_colloc(stiff_acc,src,stf,inv_mass,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: stiff_acc(1:n)
real(kind=realkind), intent(in)    :: src(1:n),stf,inv_mass(1:n)
real(kind=realkind) :: ext_force
integer :: i
                                                                    
  do i = 1, n
    ext_force = - stiff_acc(i) + src(i)*stf
    stiff_acc(i) = inv_mass(i) * ext_force
  end do 

end subroutine ustride_sum_neg_colloc
!==========================================================================

!-------------------------------------------------------------------------
subroutine ustride_sum_neg_2colloc(stiff_acc,src,stf,inv_mass,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: stiff_acc(1:n)
real(kind=realkind), intent(in)    :: src(1:n),stf,inv_mass(1:n)
real(kind=realkind) :: ext_force
integer :: i
                                                                    
  do i = 1, n
    ext_force = - stiff_acc(i) + src(i)*stf
    stiff_acc(i) = two * inv_mass(i) * ext_force
  end do 

end subroutine ustride_sum_neg_2colloc
!==========================================================================


!-------------------------------------------------------------------------
subroutine ustride_sum_neg_colloc_sum(vel,stiff,src,stf,inv_mass,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: vel(1:n)
real(kind=realkind), intent(in)    :: src(1:n),stf,inv_mass(1:n),stiff(1:n)
real(kind=realkind) :: ext_force
integer :: i
                                                                    
  do i = 1, n
    ext_force = - stiff(i) + src(i)*stf
    vel(i) = vel(i) + inv_mass(i) * ext_force
  end do 

end subroutine ustride_sum_neg_colloc_sum
!==========================================================================

!-------------------------------------------------------------------------
subroutine ustride_sum_neg_2colloc_sum(vel,stiff,src,stf,inv_mass,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: vel(1:n)
real(kind=realkind), intent(in)    :: src(1:n),stf,inv_mass(1:n),stiff(1:n)
real(kind=realkind) :: ext_force
integer :: i
                                                                    
  do i = 1, n
    ext_force = - stiff(i) + src(i)*stf
    vel(i) = vel(i) + two * inv_mass(i) * ext_force
  end do 

end subroutine ustride_sum_neg_2colloc_sum
!==========================================================================


!--------------------------------------------------------------------------
subroutine ustride_sum_neg_colloc_coefv(vel,stiff_acc,coefv,inv_mass,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: vel(1:n)
real(kind=realkind), intent(in)    :: inv_mass(1:n),stiff_acc(1:n)
double precision, intent(in)       :: coefv
integer             :: i
                                                                    
  do i = 1, n
    vel(i) = vel(i) - coefv * inv_mass(i) * stiff_acc(i)
  end do 

end subroutine ustride_sum_neg_colloc_coefv
!==========================================================================


!--------------------------------------------------------------------------
subroutine ustride_sum_neg_2colloc_coefv(vel,stiff_acc,coefv,inv_mass,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: vel(1:n)
real(kind=realkind), intent(in)    :: inv_mass(1:n),stiff_acc(1:n)
double precision, intent(in)       :: coefv
integer             :: i
                                                                    
  do i = 1, n
    vel(i) = vel(i) - two * coefv * inv_mass(i) * stiff_acc(i)
  end do 

end subroutine ustride_sum_neg_2colloc_coefv
!==========================================================================


!-------------------------------------------------------------------------
subroutine ustride_sumneg_colloc(vel,coeff,inv_mass,ext_force,n)

integer, intent(in) :: n
real(kind=realkind), intent(inout) :: vel(1:n)
real(kind=realkind), intent(in) :: inv_mass(1:n),ext_force(1:n)
real(kind=realkind) :: tmp
double precision    :: coeff
integer :: i
                                                                    
  do i = 1, n
    tmp = coeff*inv_mass(i)*ext_force(i)
    vel(i) = vel(i) - tmp
  end do 

end subroutine ustride_sumneg_colloc
!==========================================================================

!-------------------------------------------------------------------------
subroutine ustride_sum_mult_sum(vel,halfdt,acc_old,acc_new,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: vel(1:n)
real(kind=realkind), intent(in)    :: acc_old(1:n),acc_new(1:n)
double precision, intent(in)       :: halfdt
real(kind=realkind) :: tmp
integer :: i
                                                              
  do i = 1, n
    tmp    = acc_old(i) + acc_new(i)
    vel(i) = vel(i) + ( halfdt * tmp )
  end do 

end subroutine ustride_sum_mult_sum
!==========================================================================

!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
!       C O L L O C A T I O N   S U M   T E N S O R I Z A T I O N 
!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
! Routines used for the stiffness matrices
!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

!-------------------------------------------------------------------------
subroutine collocate0_1d(a,b,c,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a(0:n),b(0:n)
real(kind=realkind), intent(out) :: c(0:n)
integer :: i
                                                                    
  do i = 0, n
    c(i) = a(i) * b(i)
  end do 

end subroutine collocate0_1d
!==========================================================================

!-------------------------------------------------------------------------
subroutine collocate0_1d_existent(a,b,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: a(1:n)
real(kind=realkind), intent(in) :: b(1:n)
integer :: i

  do i = 1, n
    a(i) = a(i) * b(i)
  end do

end subroutine collocate0_1d_existent
!==========================================================================

!-------------------------------------------------------------------------
subroutine collocate0_neg1d_existent(a,b,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(inout) :: a(1:n)
real(kind=realkind), intent(in) :: b(1:n)
integer :: i

  do i = 1, n
    a(i) = -a(i) * b(i)
  end do

end subroutine collocate0_neg1d_existent
!==========================================================================

!-------------------------------------------------------------------------
subroutine collocate_sum_1d(a,b,c,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a(n),b(n),c(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: temp
integer :: i
                                                                    
  do i = 1, n
    temp = a(i) * b(i)
    s(i) = c(i) + temp
  end do 

end subroutine collocate_sum_1d
!==========================================================================

!-------------------------------------------------------------------------
subroutine collocate_sum_existent_1d(a,b,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a(n),b(n)
real(kind=realkind), intent(inout) :: s(n)
real(kind=realkind) :: temp,temp2
integer :: i
                                                                    
  do i = 1, n
    temp = a(i) * b(i)
    temp2 = s(i)
    s(i) = temp + temp2
  end do 

end subroutine collocate_sum_existent_1d
!==========================================================================

!-------------------------------------------------------------------------
subroutine collocate_2sum_1d(a,b,c1,c2,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a(n),b(n),c1(n),c2(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: temp
integer :: i
                                                                    
  do i = 1, n
    temp = c1(i) * c2(i)
    s(i) = a(i) + b(i) + temp
  end do 

end subroutine collocate_2sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate2_sum_1d(a1,b1,a2,b2,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind) :: c1,c2
real(kind=realkind), intent(out) :: s(n)
integer :: i

  s = zero
                                                                   
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    s(i) = c1 + c2
  end do 

end subroutine collocate2_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate3_sum_1d(a1,b1,a2,b2,a3,b3,s,n)

integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n)
real(kind=realkind) :: c1,c2,c3
real(kind=realkind), intent(out) :: s(n)
integer :: i

  s = zero
                                                                   
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    s(i) = c1 + c2 + c3 
  end do 

end subroutine collocate3_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate4_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,s,n)

integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n)
real(kind=realkind) :: c1,c2,c3,c4
real(kind=realkind), intent(out) :: s(n)
integer :: i

  s = zero
                                                                   
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    s(i) = c1 + c2 + c3 + c4
  end do 

end subroutine collocate4_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate5_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,s,n)

integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n),a5(n),b5(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: c1,c2,c3,c4,c5
integer :: i
                                                                    
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    s(i) = c1 + c2 + c3 + c4 + c5
  end do 

end subroutine collocate5_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate5s_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,s,n)
          
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n),a5(n),b5(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: c1,c2,c3,c4,c5
integer :: i
                                                                    
  c1=zero; c2=zero; c3=zero; c4=zero; c5=zero
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    s(i) = c1 - c2 + c3 - c4 + c5
  end do 

end subroutine collocate5s_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate5ss_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,s,n)
          
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n),a5(n),b5(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: c1,c2,c3,c4,c5
integer :: i

  c1=zero; c2=zero; c3=zero; c4=zero; c5=zero
                                                                    
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    s(i) = c1 + c2 + c3 - half*c4 + c5
  end do 

end subroutine collocate5ss_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate6s_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,b6,s,n)
          
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n),a5(n),b5(n)
real(kind=realkind), intent(in) :: b6(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: c1,c2,c3,c4,c5,c6
integer :: i
           
  c1=zero; c2=zero; c3=zero; c4=zero; c5=zero; c6=zero

  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    c6 = a5(i) * b6(i)
    s(i) = c1 + c2 + c3 + c4 + c5 - two*c6
  end do 

end subroutine collocate6s_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate7_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7,s,n)
          
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n),a5(n),b5(n)
real(kind=realkind), intent(in) :: a6(n),b6(n),a7(n),b7(n)
real(kind=realkind), intent(out) :: s(n)
real(kind=realkind) :: c1,c2,c3,c4,c5,c6,c7
integer :: i
 
  c1=zero; c2=zero; c3=zero; c4=zero; c5=zero; c6=zero; c7=zero  
                                                                   
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    c6 = a6(i) * b6(i)
    c7 = a7(i) * b7(i)
    s(i) = c1 + c2 + c3 + c4 + c5 +c6 + c7
  end do 

end subroutine collocate7_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine  collocate10s_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6, &
                               a7,a8,a9,b7,b8,s1,s2,n)
          
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),b1(n),a2(n),b2(n)
real(kind=realkind), intent(in) :: a3(n),b3(n),a4(n),b4(n),a5(n),b5(n)
real(kind=realkind), intent(in) :: a6(n),b6(n)
real(kind=realkind), intent(in) :: a7(n),a8(n),a9(n),b7(n),b8(n)
real(kind=realkind), intent(out) :: s1(n),s2(n)
real(kind=realkind) :: c1,c2,c3,c4,c5,c6,c7,c8,c9,c10
integer :: i     
  
  c1=zero; c2=zero; c3=zero; c4=zero; c5=zero
  c6=zero; c7=zero; c8=zero; c9=zero; c10=zero
                                                      
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    c6 = a6(i) * b6(i)
    c7 = a7(i) * b7(i)
    c8 = a8(i) * b8(i)
    c9 = a8(i) * b7(i)
    c10= a9(i) * b8(i)
    s1(i) = c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8
    s2(i) = -two*(c1 + c2  + c5 + c6) - half*(c3 + c4) + c9 + c10   
  end do 

end subroutine collocate10s_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate14s_sum_1d(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7, &
                               a8,b8,a9,b9,a10,b10,a11,b11,a12,b12,a13,b13, &
                               a14,b14,s1,s2,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in)  :: a1(n),b1(n),a2(n),b2(n),a3(n),b3(n)
real(kind=realkind), intent(in)  :: a4(n),b4(n),a5(n),b5(n),a6(n),b6(n)
real(kind=realkind), intent(in)  :: a7(n),b7(n),a8(n),b8(n),a9(n),b9(n)
real(kind=realkind), intent(in)  :: a10(n),b10(n),a11(n),b11(n),a12(n),b12(n)
real(kind=realkind), intent(in)  :: a13(n),b13(n),a14(n),b14(n)
real(kind=realkind), intent(out) :: s1(n),s2(n)
real(kind=realkind) :: c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14
integer :: i
                                                                    
  do i = 1, n
    c1 = a1(i) * b1(i)
    c2 = a2(i) * b2(i)
    c3 = a3(i) * b3(i)
    c4 = a4(i) * b4(i)
    c5 = a5(i) * b5(i)
    c6 = a6(i) * b6(i)
    c7 = a7(i) * b7(i)
    c8 = a8(i) * b8(i)
    c9 = a9(i) * b9(i)
    c10 = a10(i) * b10(i)
    c11 = a11(i) * b11(i)
    c12 = a12(i) * b12(i)
    c13 = a13(i) * b13(i)
    c14 = a14(i) * b14(i)
    s1(i) =  c1 + c2 + c3 + c4 + c5 +c6 + c7 +c8 +c9 + c10
    s2(i) = -c1 - c2 - c3 - c4 + c5 +c6 + c11 +c12 +c13 + c14
  end do 

end subroutine collocate14s_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate28s_sum_1d(m11,m21,m41,m12,m22,m42,m13,m23,m33,m43,&
                              X1,X2,X3,X4,X5,X6,u2,u3, &
                              z_eta_p,s_eta_mu,z_eta_m, &
                              z_xi_p,s_xi_mu,z_xi_m, &
                              s1p,s2p,s1m,s2m,n)

integer, intent(in) :: n
real(kind=realkind), intent(in), dimension(n)  :: m11,m21,m41,m12,m22,m42
real(kind=realkind), intent(in), dimension(n)  :: m13,m23,m33,m43
real(kind=realkind), intent(in), dimension(n)  :: X1,X2,X3,X4,X5,X6,u2,u3
real(kind=realkind), intent(in), dimension(n)  :: z_eta_p,s_eta_mu,z_eta_m
real(kind=realkind), intent(in), dimension(n)  :: z_xi_p,s_xi_mu,z_xi_m
real(kind=realkind), intent(out), dimension(n) :: s1p,s2p,s1m,s2m
real(kind=realkind) :: pm11,pm21,pm31,pm12,pm22,pm32
real(kind=realkind) :: p11,p21,p31,p41,p51,p12,p22,p32,p42,p52
real(kind=realkind) :: mi11,mi21,mi31,mi41,mi51,mi12,mi22,mi32,mi42,mi52
integer :: i
                                                                    
  do i = 1, n

    pm11=m13(i)*X6(i); pm21=m23(i)*X3(i); pm31=s_eta_mu(i)*u3(i)
    pm12=m33(i)*X3(i); pm22=m43(i)*X6(i); pm32=s_xi_mu(i)*u3(i)
    
    p11=m11(i)*X4(i); p21=m21(i)*X1(i); p31=m12(i)*X5(i); p41=m22(i)*X2(i)
    p51=z_eta_p(i)*u2(i)

    mi11=m11(i)*X5(i); mi21=m21(i)*X2(i); mi31=m12(i)*X4(i); mi41=m22(i)*X1(i)
    mi51=z_eta_m(i)*u2(i)
    
    p12=m11(i)*X1(i); p22=m41(i)*X4(i); p32=m12(i)*X2(i); p42=m42(i)*X5(i)
    p52=z_xi_p(i)*u2(i)

    mi12=m11(i)*X2(i); mi22=m41(i)*X5(i); mi32=m12(i)*X1(i); mi42=m42(i)*X4(i)
    mi52=z_xi_m(i)*u2(i)

    s1p(i)=pm11+pm21+pm31+ p11+ p21+ p31+ p41 +p51
    s1m(i)=pm11+pm21-pm31+mi11+mi21+mi31+mi41+mi51

    s2p(i)=pm12+pm22+pm32+p12 +p22 +p32 +p42 +p52
    s2m(i)=pm12+pm22-pm32+mi12+mi22+mi32+mi42+mi52

  end do 

end subroutine collocate28s_sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate_tensor_1d(a1,b1,d,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(0:n),b1(0:n),d(0:n)
real(kind=realkind) :: c1
real(kind=realkind), intent(out) :: s(0:n,0:n)
integer :: i,j

  s = zero
                                                                  
  do i = 0, n
     c1 = zero
     c1 = a1(i) * b1(i)
     do j = 0, n
        s(j,i)= c1 * d(j)
     enddo
  end do

end subroutine collocate_tensor_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate2_sum_tensor_1d(a1,b1,a2,b2,d,s,n)

integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(0:n),b1(0:n),a2(0:n),b2(0:n),d(0:n)
real(kind=realkind) :: c1,c2,tmp
real(kind=realkind), intent(out) :: s(0:n,0:n)
integer :: i,j
                                             
  do i = 0, n
     c1 = a1(i) * b1(i)
     c2 = a2(i) * b2(i)
     tmp= c1 + c2
     do j = 0, n
        s(j,i)= tmp * d(j)
     enddo
  end do

end subroutine collocate2_sum_tensor_1d
!==========================================================================



!--------------------------------------------------------------------------
subroutine collocate4_sum_tensor_1d(a1,b1,a2,b2,a3,b3,a4,b4,d,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(0:n),b1(0:n),a2(0:n),b2(0:n)
real(kind=realkind), intent(in) :: a3(0:n),b3(0:n),a4(0:n),b4(0:n),d(0:n)
real(kind=realkind) :: c1,c2,c3,c4,tmp
real(kind=realkind), intent(out) :: s(0:n,0:n)
integer :: i,j

  s = zero
                                                                  
  do i = 0, n
     tmp = zero; c1 = zero; c2 = zero; c3 = zero; c4 = zero; 
     c1 = a1(i) * b1(i)
     c2 = a2(i) * b2(i)
     c3 = a3(i) * b3(i)
     c4 = a4(i) * b4(i)
     tmp= c1 + c2 + c3 + c4
     do j = 0, n
        s(j,i)= tmp * d(j)
     enddo
  end do

end subroutine collocate4_sum_tensor_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine collocate4_sum_2tensor_1d(a1,b1,a2,b2,a3,b3,a4,b4,d,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(0:n),b1(0:n),a2(0:n),b2(0:n)
real(kind=realkind), intent(in) :: a3(0:n),b3(0:n),a4(0:n),b4(0:n),d(0:n)
real(kind=realkind) :: c1,c2,c3,c4,tmp
real(kind=realkind), intent(out) :: s(0:n,0:n)
integer :: i,j

  s = zero
                                                                  
  do i = 0, n
     tmp = zero; c1 = zero; c2 = zero; c3 = zero; c4 = zero; 
     c1 = a1(i) * b1(i)
     c2 = a2(i) * b2(i)
     c3 = two * a3(i) * b3(i)
     c4 = a4(i) * b4(i)
     tmp= c1 + c2 + c3 + c4
     do j = 0, n
        s(j,i)= tmp * d(j)
     enddo
  end do

end subroutine collocate4_sum_2tensor_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine sum_1d(a,b,s,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a(n),b(n)
real(kind=realkind), intent(out) :: s(n)
integer :: i
                                                                    
  do i = 1, n
    s(i) =  a(i) + b(i)
  end do                                         
                   
end subroutine sum_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine sum2_2_1d(a1,a2,s1,b1,b2,s2,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),b1(n),b2(n)
real(kind=realkind), intent(out) :: s1(n),s2(n)
integer :: i
                                                                    
  do i = 1, n
    s1(i) =  a1(i) + a2(i)
    s2(i) = b1(i) + b2(i) 
  end do                                         

end subroutine sum2_2_1d
!==========================================================================

!--------------------------------------------------------------------------
subroutine sum2_3_1d(a1,a2,s1,b1,b2,b3,s2,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),b1(n),b2(n),b3(n)
real(kind=realkind), intent(out) :: s1(n),s2(n)
integer :: i
                                                                    
  do i = 1, n
    s1(i) = a1(i) + a2(i)
    s2(i) = b1(i) + b2(i) + b3(i)    
  end do                                         
                   
end subroutine sum2_3_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum2s_3_3_1d(a1,a2,s1,b1,b2,b3,s2,c1,c2,c3,s3,n)

integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),b1(n),b2(n),b3(n)
real(kind=realkind), intent(in) :: c1(n),c2(n),c3(n)
real(kind=realkind), intent(out) :: s1(n),s2(n),s3(n)
integer :: i
                                                                    
  do i = 1, n
    s1(i) = a1(i) + a2(i)
    s2(i) = b1(i) + b2(i) + b3(i)    
    s3(i) = c1(i) + c2(i) + c3(i)    
  end do                                         
                   
end subroutine sum2s_3_3_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum3s_4_4_1d(a1,a2,a3,s1,b1,b2,b3,b4,s2,c1,c2,c3,c4,s3,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),a3(n),b1(n),b2(n),b3(n),b4(n)
real(kind=realkind), intent(in) :: c1(n),c2(n),c3(n),c4(n)
real(kind=realkind), intent(out) :: s1(n),s2(n),s3(n)
integer :: i
                                                                    
  do i = 1, n
    s1(i) = a1(i) + a2(i) + a3(i)
    s2(i) = b1(i) + b2(i) + b3(i) + b4(i)   
    s3(i) = c1(i) + c2(i) + c3(i) + c4(i)    
  end do                                         
                   
end subroutine sum3s_4_4_1d
!=========================================================================


!--------------------------------------------------------------------------
subroutine sum2s_1d(a1,s1,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n)
real(kind=realkind), intent(inout) :: s1(n)
real(kind=realkind) :: tmp1(n)
integer :: i
  
  tmp1=s1
                                                                    
  do i = 1, n
    s1(i) = tmp1(i) + a1(i) 
  end do                                         
                   
end subroutine sum2s_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum3s_1d(a1,a2,s1,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n)
real(kind=realkind), intent(inout) :: s1(n)
real(kind=realkind) :: tmp1(n)
integer :: i
  
  tmp1=s1
                                                                    
  do i = 1, n
    s1(i) = tmp1(i) + a1(i) + a2(i)
  end do                                         
                   
end subroutine sum3s_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum3s_3_1d(a1,a2,s1,b1,b2,s2,c1,c2,s3,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),b1(n),b2(n),c1(n),c2(n)
real(kind=realkind), intent(inout) :: s1(n),s2(n),s3(n)
real(kind=realkind) :: tmp1(n),tmp2(n),tmp3(n)
integer :: i
  
  tmp1=s1; tmp2=s2; tmp3=s3
                                                                    
  do i = 1, n
    s1(i) = tmp1(i) + a1(i) + a2(i)
    s2(i) = tmp2(i) + b1(i) + b2(i)      
    s3(i) = tmp3(i) + c1(i) + c2(i)      
  end do                                         
                   
end subroutine sum3s_3_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum2_3_3_1d(a1,a2,s1,b1,b2,s2,c1,c2,s3,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),b1(n),b2(n),c1(n),c2(n)
real(kind=realkind), intent(inout) :: s2(n),s3(n)
real(kind=realkind), intent(out) :: s1(n)
real(kind=realkind) :: tmp2(n),tmp3(n)
integer :: i

  tmp2=s2; tmp3=s3
                                                                    
  do i = 1, n
    s1(i) = a1(i) + a2(i)
    s2(i) = tmp2(i) + b1(i) + b2(i)      
    s3(i) = tmp3(i) + c1(i) + c2(i)      
  end do                                         
                   
end subroutine sum2_3_3_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum3_4_4_1d(a1,a2,a3,s1,b1,b2,b3,s2,c1,c2,c3,s3,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),a3(n),b1(n),b2(n),b3(n)
real(kind=realkind), intent(in) :: c1(n),c2(n),c3(n)
real(kind=realkind), intent(inout) :: s2(n),s3(n)
real(kind=realkind), intent(out) :: s1(n)
real(kind=realkind) :: tmp2(n),tmp3(n)
integer :: i

  tmp2=s2; tmp3=s3
                                                                    
  do i = 1, n
    s1(i) = a1(i) + a2(i) + a3(i)
    s2(i) = tmp2(i) + b1(i) + b2(i) + b3(i)      
    s3(i) = tmp3(i) + c1(i) + c2(i) + c3(i)     
  end do                                         
                   
end subroutine sum3_4_4_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine sum4_3_1d(a1,a2,a3,s1,b1,b2,b3,s2,c1,c2,c3,s3,n)
  
integer, intent(in) :: n
real(kind=realkind), intent(in) :: a1(n),a2(n),a3(n),b1(n),b2(n),b3(n)
real(kind=realkind), intent(in) :: c1(n),c2(n),c3(n)
real(kind=realkind), intent(inout) :: s1(n),s2(n),s3(n)
integer :: i

  do i = 1, n
    s1(i) = s1(i) + a1(i) + a2(i) + a3(i)
    s2(i) = s2(i) + b1(i) + b2(i) + b3(i)
    s3(i) = s3(i) + c1(i) + c2(i) + c3(i)
  end do

end subroutine sum4_3_1d
!=========================================================================

!--------------------------------------------------------------------------
subroutine tensor_sum_2d(a,b,c,fz,n)

integer, intent(in) :: n
real(kind=realkind), dimension(0:n), intent(in) :: a,b,c
real(kind=realkind), dimension(0:n,0:n), intent(out) :: fz
integer :: i,j

  do j = 0, n
    fz(0,j) = a(j)
    do i = 1, n
      fz(i,j) = b(i) * c(j)
    enddo
  enddo

end subroutine tensor_sum_2d
!=========================================================================

!--------------------------------------------------------------------------
subroutine add_to_axis_2d(a,b,n)

integer, intent(in) :: n
real(kind=realkind), dimension(0:n), intent(in) :: a
real(kind=realkind), dimension(0:n,0:n), intent(inout) :: b
integer :: j

  do j = 0, n
    b(0,j) = b(0,j) + a(j)
  enddo

end subroutine add_to_axis_2d
!=========================================================================

!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

!========================
end module unit_stride_colloc
!========================