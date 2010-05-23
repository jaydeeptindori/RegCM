!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
!
!    This file is part of ICTP RegCM.
!
!    ICTP RegCM is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    ICTP RegCM is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with ICTP RegCM.  If not, see <http://www.gnu.org/licenses/>.
!
!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

      subroutine humid1(t,q,ps,sigma,im,jm,km)
      use mod_constants , only : tzero , rtzero , lh0 , lh1 , lsvp1 ,   &
               &                 lsvp2 , ep2
      use mod_preproc_param , only : ptop
      implicit none
!
! Dummy arguments
!
      integer :: im , jm , km
      real(4) , dimension(im,jm) :: ps
      real(4) , dimension(im,jm,km) :: q , t
      real(4) , dimension(km) :: sigma
      intent (in) im , jm , km , ps , sigma , t
      intent (inout) q
!
! Local variables
!
      real(4) :: hl , p , qs , satvp
      integer :: i , j , k
!
!     THIS ROUTINE REPLACES SPECIFIC HUMIDITY BY RELATIVE HUMIDITY
!     DATA ON SIGMA LEVELS
!
      do k = 1 , km
        do j = 1 , jm
          do i = 1 , im
            p = sigma(k)*(ps(i,j)-ptop) + ptop
            hl = lh0 - lh1*(t(i,j,k)-tzero)           ! LATENT HEAT OF EVAP.
            satvp = lsvp1*exp(lsvp2*hl*(rtzero-1./t(i,j,k)))
                                                      ! SATURATION VAP PRESS.
            qs = ep2*satvp/(p-satvp)                  ! SAT. MIXING RATIO
            q(i,j,k) = q(i,j,k)/qs
          end do
        end do
      end do
      end subroutine humid1