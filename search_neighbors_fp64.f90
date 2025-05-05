program search_neighbors

  implicit none

  integer, parameter :: N = 1000
  real(8) :: x(N), y(N), z(N)
  integer :: neighbors(N, N), num_neighbors(N)
  real, parameter :: R_CUT = 0.2
  real(8) :: dx, dy, dz, r

  integer :: i, j, count, iter, k

  real(8) t_start,t_end,tt

  iter = 5000

!   ! Initialize particle positions randomly
!   do i = 1, N
!      call random_number(x(i))
!      call random_number(y(i))
!      call random_number(z(i))
!   end do

!   open(unit = 10, file = 'coordinates_1000.dat')
!   do i = 1, N
!     write(10,*) x(i),y(i),z(i)
!   enddo
!   close(10)

  open(unit = 10, file = 'coordinates_1000.dat')
  do i = 1, N
    read(10,*) x(i),y(i),z(i)
  enddo
  close(10)

  ! Search for neighbors closer than R_CUT
  call cpu_time(t_start)
  do k = 1,iter
   do i = 1, N
      count = 0
      do j = 1, N
         if (i /= j) then
            
            dx = x(i) - x(j)
            dy = y(i) - y(j)
            dz = z(i) - z(j)
            r = sqrt(dx*dx + dy*dy + dz*dz)
            if (r <= R_CUT) then
               count = count + 1
               neighbors(i, count) = j
            end if
         end if
      end do
      num_neighbors(i) = count
   end do
   enddo
   call cpu_time(t_end)
   

  ! Print out neighbors of each particle
  do i = N, N
     write (*, '(A,I6,A)', advance='no') 'Particle ', i, ' neighbors: '
     do j = 1, num_neighbors(i)
        write (*, '(I6)', advance='no') neighbors(i, j)
     end do
  end do

  write(*,*) 'time =', t_end-t_start

end program search_neighbors
