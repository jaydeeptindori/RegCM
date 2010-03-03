      subroutine interp
 
      use mod_domain
      use mod_aa
      use mod_block
      use mod_const
      use mod_maps
      implicit none
!
! Local variables
!
      real(4) :: dsgrid
      logical :: flag
      real(8) :: h1 , h2 , v21 , xx , yy
      integer :: i , ii , iindex , j , jindex
      real(8) , dimension(iter,jter) :: xin1 , xin2
      real(8) , external :: bint
!
      do i = 1 , iter
        do j = 1 , jter
          xin1(i,j) = 0.0
          xin2(i,j) = 0.0
        end do
      end do
      do ii = 1 , nobs
        jindex = (xobs(ii)-grdlnmn)*nnc + 1.1
        iindex = (yobs(ii)-grdltmn)*nnc + 1.1
        if ( iindex>iter .or. jindex>jter ) then
          print 99001 , ii , xobs(ii) , nnc , yobs(ii) , iindex , jindex
          stop 400
        end if
        h1 = max(ht(ii),0.0)
        xin1(iindex,jindex) = h1/100.
        h2 = max(ht2(ii),0.0)
        xin2(iindex,jindex) = h2/100000.
      end do
 
      flag = .false.
      dsgrid = float(ntypec)/60.
 
      do i = 1 , iy - 1
        do j = 1 , jx - 1
 
          yy = -(grdltmn-xlat(i,j))/dsgrid + 1.0
          if ( grdlnmn<=-180.0 .and. xlon(i,j)>0.0 ) xlon(i,j)          &
             & = xlon(i,j) - 360.
          xx = -(grdlnmn-xlon(i,j))/dsgrid + 1.0
 
!         yy and xx are the exact index values of a point i,j of the
!         mesoscale mesh when projected onto an earth-grid of lat_s
!         and lon_s for which terrain observations are available.  it
!         is assumed that the earth grid has equal spacing in both
!         latitude and longitude.
 
          h1 = max(bint(yy,xx,xin1,iter,jter,flag),0.D0)*100.
          h2 = max(bint(yy,xx,xin2,iter,jter,flag),0.D0)*100000.
          htgrid(i,j) = h1
          v21 = h2 - h1**2
          htsdgrid(i,j) = sqrt(max(v21,0.D0))
 
        end do
      end do
 
99001 format (1x,'ii = ',i6,' xobs(ii) = ',f10.4,' incr = ',i3,         &
             &'yobs(ii) = ',f10.4,' iindex = ',i10,'  jindex = ',i10)
 
      end subroutine interp