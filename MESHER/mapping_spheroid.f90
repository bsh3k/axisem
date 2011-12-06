module mapping_spheroid
!
implicit none
public :: map_spheroid
private
contains
!
!dk map_spheroid
double precision function map_spheroid(xi,eta,crd_nodes,idir)
!
!       We are working in polar coordinates here: theta
! is the latitude.
! idir = 1 : returns cylindrical radius s
! idir = 2 : returns axial coordinate z
!
  double precision :: xi, eta
  double precision, dimension(8,2),intent(in) :: crd_nodes
  integer :: idir
  double precision :: abot,bbot,atop,btop
  double precision :: thetabarbot,dthetabot
  double precision :: thetabartop,dthetatop
  double precision :: sbot,zbot,stop,ztop
  double precision :: sbar,ds,slope,intersect
!
  write(61,*)'map_spheroid!'

  map_spheroid = 0.
  call compute_parameters_sph(crd_nodes,abot,bbot,atop,btop,&
                              thetabarbot,dthetabot,thetabartop,dthetatop)
  call compute_sz_xi(sbot,zbot,xi,abot,bbot,thetabarbot,dthetabot)
  call compute_sz_xi(stop,ztop,xi,atop,btop,thetabartop,dthetatop)
  sbar = .5 * (sbot+stop) ; ds = stop-sbot

  write(61,*)
  write(61,*)'ds,sbar:',ds,sbar

  if (idir == 1) then
     write(61,*)'Direction 1!'
     map_spheroid = sbar+ds*eta*.5

  elseif (idir == 2) then
     write(61,*)'Direction 2!'
     if (abs(ds)>1.e-7) then
        write(61,*)'abs > 1.d-10... intersect and slope'
        intersect = (zbot*stop-ztop*sbot)/ds
        slope = (ztop-zbot)/ds
        map_spheroid = slope*(sbar+.5*ds*eta)+intersect
     else
        map_spheroid = .5*(zbot+ztop)+eta*(ztop-zbot)*.5
     end if
     write(61,*)'stop,sbot:',stop,sbot
     write(61,*)'ztop,zbot:',ztop,zbot
  end if
  write(61,*)'map_spheroid',map_spheroid

write(61,*)''

end function map_spheroid
!
!dk compute_parameters_sph---------------------------------
subroutine compute_parameters_sph(crd_nodes,abot,bbot,atop,btop,&
                              thetabarbot,dthetabot,thetabartop,dthetatop)
!
  double precision , dimension(8,2),intent(in) :: crd_nodes
  double precision ,intent(out) :: abot,bbot,atop,btop
  double precision ,intent(out) :: thetabarbot,dthetabot
  double precision ,intent(out) :: thetabartop,dthetatop
  double precision  :: s1,z1,s3,z3,s5,z5,s7,z7
  double precision  :: theta1,theta3,theta5,theta7
!
  s1 = crd_nodes(1,1) ; z1 = crd_nodes(1,2)
  s3 = crd_nodes(3,1) ; z3 = crd_nodes(3,2)
  s5 = crd_nodes(5,1) ; z5 = crd_nodes(5,2)
  s7 = crd_nodes(7,1) ; z7 = crd_nodes(7,2)
!
  call compute_ab(abot,bbot,s1,z1,s3,z3)
  call compute_theta(theta1,s1,z1,abot,bbot)
  call compute_theta(theta3,s3,z3,abot,bbot)
!
  call compute_ab(atop,btop,s7,z7,s5,z5)
  call compute_theta(theta5,s5,z5,atop,btop)
  call compute_theta(theta7,s7,z7,atop,btop)
!
  thetabarbot = .5*(theta1+theta3)
  dthetabot = theta3-theta1
  thetabartop = .5*(theta7+theta5)
  dthetatop = theta5 -theta7
!
end subroutine compute_parameters_sph
!----------------------------------------------------------
!
!dk compute_ab--------------------------------------
subroutine compute_ab(a,b,s1,z1,s2,z2)
!
  double precision , intent(out) :: a,b
  double precision , intent(in) :: s1,z1,s2,z2
!
  a = sqrt(abs((s2**2*z1**2-z2**2*s1**2)/(z1**2-z2**2)))
  b = sqrt(abs((z1**2*s2**2-z2**2*s1**2)/(s2**2-s1**2)))
!
end subroutine compute_ab
!---------------------------------------------------
!
!dk compute_theta---------------------------
subroutine compute_theta(theta,s,z,a,b)
!
!       This routine returns the latitude theta, given s and z.
!
  double precision , intent(out) :: theta
  double precision , intent(in) :: s,z,a,b
  double precision :: pi
!
  pi = 2.*asin(1.)
!
  if (s /= 0. ) then
     theta=atan(z*a/(s*b))
  else
     if (z>0.) theta=.5*pi
     if (z<0.) theta=-.5*pi
  end if
!
end subroutine compute_theta
!-----------------------------------
!dk compute_sz_xi------------------------------------------------------
subroutine compute_sz_xi(s,z,xi,a,b,thetabar,dtheta)
!
  double precision , intent(out) :: s,z
  double precision , intent(in) :: xi, a, b, thetabar,dtheta
!
  s = a*cos(thetabar+xi*.5*dtheta)
  z = b*sin(thetabar+xi*.5*dtheta)
!
end subroutine compute_sz_xi

end module mapping_spheroid