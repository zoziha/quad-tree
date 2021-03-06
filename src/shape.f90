! 形状 (暂不服从开闭原则)，支持：点、线、圆、正方形、长方形、球、正方体、长方体。
module shape_m

    use, intrinsic :: iso_fortran_env, only: rk => real32, stdout => output_unit
    implicit none
    private

    public :: point_t, shape_t, cuboid_t, cube_t, square_t, rectangle_t, line_t, sphere_t, circle_t

    !> 点的坐标
    !> 支持1~3维
    type point_t
        real(rk), allocatable :: x(:) !! 坐标
        integer, allocatable :: id    !! 唯一标识
    end type point_t

    ! 形状类型
    type, abstract :: shape_t
    contains
        procedure(shape_t_contains), deferred :: contains       !! 查询点是否在形状内
        procedure(shape_t_intersects), deferred :: intersects   !! 查询是否相交
        procedure(shape_t_show), deferred :: show               !! 显示形状
    end type shape_t

    abstract interface
        logical pure function shape_t_contains(self, point)
            import shape_t, point_t
            class(shape_t), intent(in) :: self
            type(point_t), intent(in) :: point
        end function shape_t_contains
        logical pure function shape_t_intersects(self, other)
            import shape_t
            class(shape_t), intent(in) :: self
            class(shape_t), intent(in) :: other
        end function shape_t_intersects
        subroutine shape_t_show(self)
            import shape_t
            class(shape_t), intent(in) :: self
        end subroutine shape_t_show
    end interface

    type, extends(shape_t) :: line_t
        real(rk) :: center(1)
        real(rk) :: length
    contains
        procedure :: contains => line_t_contains
        procedure :: intersects => line_t_intersects
        procedure :: show => line_t_show
    end type line_t

    type, extends(shape_t) :: circle_t
        real(rk) :: center(2)
        real(rk) :: radius
    contains
        procedure :: contains => circle_t_contains
        procedure :: intersects => circle_t_intersects
        procedure :: show => circle_t_show
    end type circle_t

    type, extends(shape_t) :: square_t
        real(rk) :: center(2)
        real(rk) :: length
    contains
        procedure :: contains => square_t_contains
        procedure :: intersects => square_t_intersects
        procedure :: show => square_t_show
    end type square_t

    type, extends(shape_t) :: rectangle_t
        real(rk) :: center(2)
        real(rk) :: length(2)
    contains
        procedure :: contains => rectangle_t_contains
        procedure :: intersects => rectangle_t_intersects
        procedure :: show => rectangle_t_show
    end type rectangle_t

    type, extends(shape_t) :: sphere_t
        real(rk) :: center(3)
        real(rk) :: radius
    contains
        procedure :: contains => sphere_t_contains
        procedure :: intersects => sphere_t_intersects
        procedure :: show => sphere_t_show
    end type sphere_t

    type, extends(shape_t) :: cube_t
        real(rk) :: center(3)
        real(rk) :: length
    contains
        procedure :: contains => cube_t_contains
        procedure :: intersects => cube_t_intersects
        procedure :: show => cube_t_show
    end type cube_t

    type, extends(shape_t) :: cuboid_t
        real(rk) :: center(3)
        real(rk) :: length(3)
    contains
        procedure :: contains => cuboid_t_contains
        procedure :: intersects => cuboid_t_intersects
        procedure :: show => cuboid_t_show
    end type cuboid_t

contains

    !> func1 = x - y*0.5
    elemental real(rk) function func1(x, y)
        real(rk), intent(in) :: x, y
        func1 = x - y*0.5_rk
    end function func1

    !> func2 = x + y*0.5
    elemental real(rk) function func2(x, y)
        real(rk), intent(in) :: x, y
        func2 = x + y*0.5_rk
    end function func2

    logical pure function line_t_contains(self, point)
        class(line_t), intent(in) :: self
        type(point_t), intent(in) :: point
        line_t_contains = 2.0_rk*abs(self%center(1) - point%x(1)) < self%length
    end function line_t_contains

    logical pure function circle_t_contains(self, point)
        class(circle_t), intent(in) :: self
        type(point_t), intent(in) :: point
        associate (x => self%center, r => self%radius)
            circle_t_contains = hypot(point%x(1) - x(1), point%x(2) - x(2)) < r
        end associate
    end function circle_t_contains

    logical pure function square_t_contains(self, point)
        class(square_t), intent(in) :: self
        type(point_t), intent(in) :: point
        associate (x => self%center, l => self%length)
            square_t_contains = (point%x(1) > func1(x(1), l)) &
                                .and. (point%x(1) < func2(x(1), l)) &
                                .and. (point%x(2) > func1(x(2), l)) &
                                .and. (point%x(2) < func2(x(2), l))
        end associate
    end function square_t_contains

    logical pure function rectangle_t_contains(self, point)
        class(rectangle_t), intent(in) :: self
        type(point_t), intent(in) :: point
        associate (x => self%center, l => self%length)
            rectangle_t_contains = (point%x(1) > func1(x(1), l(1))) &
                                   .and. (point%x(1) < func2(x(1), l(1))) &
                                   .and. (point%x(2) > func1(x(2), l(2))) &
                                   .and. (point%x(2) < func2(x(2), l(2)))
        end associate
    end function rectangle_t_contains

    logical pure function sphere_t_contains(self, point)
        class(sphere_t), intent(in) :: self
        type(point_t), intent(in) :: point
        associate (x => self%center, r => self%radius)
            sphere_t_contains = norm2(point%x - x) < r
        end associate
    end function sphere_t_contains

    logical pure function cube_t_contains(self, point)
        class(cube_t), intent(in) :: self
        type(point_t), intent(in) :: point
        associate (x => self%center, l => self%length)
            cube_t_contains = (point%x(1) > func1(x(1), l)) &
                              .and. (point%x(1) < func2(x(1), l)) &
                              .and. (point%x(2) > func1(x(2), l)) &
                              .and. (point%x(2) < func2(x(2), l)) &
                              .and. (point%x(3) > func1(x(3), l)) &
                              .and. (point%x(3) < func2(x(3), l))
        end associate
    end function cube_t_contains

    logical pure function cuboid_t_contains(self, point)
        class(cuboid_t), intent(in) :: self
        type(point_t), intent(in) :: point
        associate (x => self%center, l => self%length)
            cuboid_t_contains = (point%x(1) > func1(x(1), l(1))) &
                                .and. (point%x(1) < func2(x(1), l(1))) &
                                .and. (point%x(2) > func1(x(2), l(2))) &
                                .and. (point%x(2) < func2(x(2), l(2))) &
                                .and. (point%x(3) > func1(x(3), l(3))) &
                                .and. (point%x(3) < func2(x(3), l(3)))
        end associate
    end function cuboid_t_contains

    logical pure function line_t_intersects(self, other)
        class(line_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (line_t)
            associate (x => 2.0_rk*abs(self%center(1) - other%center(1)), &
                       l => self%length, &
                       l_ => other%length)
                line_t_intersects = x < (l + l_)
            end associate
        end select
    end function line_t_intersects

    logical pure function circle_t_intersects(self, other)
        class(circle_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (square_t)
            associate (x => abs(other%center - self%center), r => self%radius, l => other%length)
            if (any(x >= func2(r, l))) then
                circle_t_intersects = .false.
                return
            end if
            if (all(x < l*0.5)) then
                circle_t_intersects = .true.
                return
            end if
            circle_t_intersects = norm2(func1(x, l)) < r
            end associate
        type is (rectangle_t)
            associate (x => abs(other%center - self%center), r => self%radius, l => other%length)
            if (any(x >= func2(r, l))) then
                circle_t_intersects = .false.
                return
            end if
            if (all(x < l*0.5)) then
                circle_t_intersects = .true.
                return
            end if
            circle_t_intersects = norm2(func1(x, l)) < r
            end associate
        end select
    end function circle_t_intersects

    logical pure function square_t_intersects(self, other)
        class(square_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (square_t)
            associate (lb => func1(self%center, self%length), &
                       rt => func2(self%center, self%length), &
                       lb_ => func1(other%center, other%length), &
                       rt_ => func2(other%center, other%length))
                square_t_intersects = any(lb < rt_) .or. any(rt > lb_)
            end associate
        type is (rectangle_t)
            associate (lb => func1(self%center, self%length), &
                       rt => func2(self%center, self%length), &
                       lb_ => func1(other%center, other%length), &
                       rt_ => func2(other%center, other%length))
                square_t_intersects = any(lb < rt_) .or. any(rt > lb_)
            end associate
        end select
    end function square_t_intersects

    logical pure function rectangle_t_intersects(self, other)
        class(rectangle_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (square_t)
            associate (lb => func1(self%center, self%length), &
                       rt => func2(self%center, self%length), &
                       lb_ => func1(other%center, other%length), &
                       rt_ => func2(other%center, other%length))
                rectangle_t_intersects = any(lb < rt_) .or. any(rt > lb_)
            end associate
        type is (rectangle_t)
            associate (lb => func1(self%center, self%length), &
                       rt => func2(self%center, self%length), &
                       lb_ => func1(other%center, other%length), &
                       rt_ => func2(other%center, other%length))
                rectangle_t_intersects = any(lb < rt_) .or. any(rt > lb_)
            end associate
        end select
    end function rectangle_t_intersects

    logical pure function sphere_t_intersects(self, other)
        class(sphere_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (cube_t)
            associate (x => abs(other%center - self%center), r => self%radius, l => other%length)
            if (any(x >= func2(r, l))) then
                sphere_t_intersects = .false.
                return
            end if
            if (all(x < l*0.5)) then
                sphere_t_intersects = .true.
                return
            end if
            sphere_t_intersects = norm2(func1(x, l)) < r
            end associate
        type is (cuboid_t)
            associate (x => abs(other%center - self%center), r => self%radius, l => other%length)
            if (any(x >= func2(r, l))) then
                sphere_t_intersects = .false.
                return
            end if
            if (all(x < l*0.5)) then
                sphere_t_intersects = .true.
                return
            end if
            sphere_t_intersects = norm2(func1(x, l)) < r
            end associate
        end select
    end function sphere_t_intersects

    logical pure function cube_t_intersects(self, other)
        class(cube_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (cuboid_t)
            associate (lbb => func1(self%center, self%length), &
                       rtf => func2(self%center, self%length), &
                       lbb_ => func1(other%center, other%length), &
                       rtf_ => func2(other%center, other%length))
                cube_t_intersects = any(lbb < rtf_) .or. any(rtf > lbb_)
            end associate
        type is (cube_t)
            associate (lbb => func1(self%center, self%length), &
                       rtf => func2(self%center, self%length), &
                       lbb_ => func1(other%center, other%length), &
                       rtf_ => func2(other%center, other%length))
                cube_t_intersects = any(lbb < rtf_) .or. any(rtf > lbb_)
            end associate
        end select
    end function cube_t_intersects

    logical pure function cuboid_t_intersects(self, other)
        class(cuboid_t), intent(in) :: self
        class(shape_t), intent(in) :: other
        select type (other)
        type is (cuboid_t)
            associate (lbb => func1(self%center, self%length), &
                       rtf => func2(self%center, self%length), &
                       lbb_ => func1(other%center, other%length), &
                       rtf_ => func2(other%center, other%length))
                cuboid_t_intersects = any(lbb < rtf_) .or. any(rtf > lbb_)
            end associate
        type is (cube_t)
            associate (lbb => func1(self%center, self%length), &
                       rtf => func2(self%center, self%length), &
                       lbb_ => func1(other%center, other%length), &
                       rtf_ => func2(other%center, other%length))
                cuboid_t_intersects = any(lbb < rtf_) .or. any(rtf > lbb_)
            end associate
        end select
    end function cuboid_t_intersects

    subroutine line_t_show(self)
        class(line_t), intent(in) :: self
        write (stdout, '(2(a,es10.3))') "line_t: center = [", self%center, " ], length = ", self%length
    end subroutine line_t_show

    subroutine circle_t_show(self)
        class(circle_t), intent(in) :: self
        write (stdout, '(a,2(es10.3,1x),a,es10.3)') "circle_t: center = [", self%center, &
            " ], radius = ", self%radius
    end subroutine circle_t_show

    subroutine square_t_show(self)
        class(square_t), intent(in) :: self
        write (stdout, '(a,2(es10.3,1x),a,es10.3)') "square_t: center = [", self%center, &
            " ], length = ", self%length
    end subroutine square_t_show

    subroutine rectangle_t_show(self)
        class(rectangle_t), intent(in) :: self
        write (stdout, '(2(a,2(es10.3,1x)))') "rectangle_t: center = [", self%center, &
            " ], length = ", self%length
    end subroutine rectangle_t_show

    subroutine sphere_t_show(self)
        class(sphere_t), intent(in) :: self
        write (stdout, '(a,3(es10.3,1x),a,es10.3)') "sphere_t: center = [", self%center, &
            " ], radius = ", self%radius
    end subroutine sphere_t_show

    subroutine cube_t_show(self)
        class(cube_t), intent(in) :: self
        write (stdout, '(a,3(es10.3,1x),a,es10.3)') "cube_t: center = [", self%center, &
            " ], length = ", self%length
    end subroutine cube_t_show

    subroutine cuboid_t_show(self)
        class(cuboid_t), intent(in) :: self
        write (stdout, '(2(a,3(es10.3,1x)))') "cuboid_t: center = [", self%center, &
            " ], length = ", self%length
    end subroutine cuboid_t_show

end module shape_m
