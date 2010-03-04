      subroutine uvrot4nx(u,v,dlon,dlat,clon,clat,gridfc,jx,iy,ll,      &
                        & pollon,pollat,lgtype)
      implicit none
!
! Dummy arguments
!
      real :: clat , clon , gridfc , pollat , pollon
      integer :: iy , jx , ll
      character(6) :: lgtype
      real , dimension(jx,iy) :: dlat , dlon
      real , dimension(jx,iy,ll) :: u , v
      intent (in) clat , clon , dlat , dlon , gridfc , iy , jx ,        &
                & lgtype , ll , pollat , pollon
      intent (inout) u , v
!
! Local variables
!
      real :: cosdel , d , pir180 , polcphi , pollam , polphi ,         &
            & polsphi , sindel , us , vs , x , xc , xs , zarg1 , zarg2 ,&
            & znorm , zphi , zrla , zrlap
      integer :: i , j , l
!
!     CHANGE U AND V FROM TRUE (N,E) TO MAP VALUES (X,Y)
!
!     FOR ROTATED MERCATOR PROJECTION
!UVUSVS   -   ROTATES THE TWO WINDCOMPONENTS U AND V AT POINT
!     DLON,DLAT TO THE WINDCOMPONENTS US AND VS IN A
!     ROTATED POLE GRID WHERE THE ORIGIN IS LOCATED
!     AT POLLON,POLLAT
!**   CALL  :   CALL UVUSVS(U,V,US,VS,DLON,DLAT,POLLON,POLLAT)
!**   AUTHOR:   D.MAJEWSKI
!
      pir180 = atan(1.)/45.
      if ( lgtype=='ROTMER' ) then
        if ( pollat>0. ) then
          pollam = pollon + 180.
          polphi = 90. - pollat
        else
          polphi = 90. + pollat
          pollam = pollon
        end if
        if ( pollam>180. ) pollam = pollam - 360.
 
        polcphi = cos(pir180*polphi)
        polsphi = sin(pir180*polphi)
 
        do j = 1 , iy
          do i = 1 , jx
            zphi = dlat(i,j)*pir180
            zrla = dlon(i,j)*pir180
            if ( dlat(i,j)>89.999999 ) zrla = 0.0
            zrlap = pollam*pir180 - zrla
            zarg1 = polcphi*sin(zrlap)
            zarg2 = polsphi*cos(zphi) - polcphi*sin(zphi)*cos(zrlap)
            znorm = 1.0/sqrt(zarg1**2+zarg2**2)
            sindel = zarg1*znorm
            cosdel = zarg2*znorm
            do l = 1 , ll
              us = u(i,j,l)*cosdel + v(i,j,l)*sindel
              vs = -u(i,j,l)*sindel + v(i,j,l)*cosdel
              u(i,j,l) = us
              v(i,j,l) = vs
            end do
          end do
        end do
      else
        do j = 1 , iy
          do i = 1 , jx
            if ( (clon>=0.0 .and. dlon(i,j)>=0.) .or.                   &
               & (clon<0.0 .and. dlon(i,j)<0.) ) then
              x = (clon-dlon(i,j))*pir180*gridfc
            else if ( clon>=0.0 ) then
              if ( abs(clon-(dlon(i,j)+360.))<abs(clon-dlon(i,j)) ) then
                x = (clon-(dlon(i,j)+360.))*pir180*gridfc
              else
                x = (clon-dlon(i,j))*pir180*gridfc
              end if
            else if ( abs(clon-(dlon(i,j)-360.))<abs(clon-dlon(i,j)) )  &
                    & then
              x = (clon-(dlon(i,j)-360.))*pir180*gridfc
            else
              x = (clon-dlon(i,j))*pir180*gridfc
            end if
            xs = sin(x)
            xc = cos(x)
            if ( clat>=0. ) then
              do l = 1 , ll
                d = u(i,j,l)*xc - v(i,j,l)*xs
                v(i,j,l) = u(i,j,l)*xs + v(i,j,l)*xc
                u(i,j,l) = d
              end do
            else
              do l = 1 , ll
                d = u(i,j,l)*xc + v(i,j,l)*xs
                v(i,j,l) = v(i,j,l)*xc - u(i,j,l)*xs
                u(i,j,l) = d
              end do
            end if
          end do
        end do
      end if
      end subroutine uvrot4nx