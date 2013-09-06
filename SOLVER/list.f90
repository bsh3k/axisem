module linked_list
  implicit none

  private
  public :: list

  type :: link
     private
     type(link), pointer        :: next => null()   ! next link in list
     type(link), pointer        :: prev => null()   ! next link in list
     integer                    :: ldata
     contains
     procedure, pass :: getData      ! return value pointer
     procedure, pass :: getNextLink  ! return next pointer
     procedure, pass :: setNextLink  ! set next pointer
     procedure, pass :: getPrevLink  ! return next pointer
     procedure, pass :: setPrevLink  ! set next pointer
  end type link

  interface link
     procedure constructor ! construct/initialize a link
  end interface

  type :: list
     private
     class(link), pointer :: firstLink => null()    ! first link in list
     class(link), pointer :: lastLink => null()     ! last link in list
     class(link), pointer :: currentLink => null()  ! iterator
     contains
     procedure, pass :: append          ! append an element to the list
     procedure, pass :: getFirst        ! return first element
     procedure, pass :: getLast         ! return last element
     procedure, pass :: getCurrent      ! iterator, can be moved with getNext
                                        ! if not set, returns first element
     procedure, pass :: resetCurrent    ! reset the iterator
     procedure, pass :: getNext         ! get the next element
                                        ! if current not set, returns first element
     procedure, pass :: getPrev         ! get the previous element
                                        ! if current not set, returns last element
  end type list

contains

function getNextLink(this)
  class(link)           :: this
  type(link), pointer   :: getNextLink
  getNextLink => this%next
end function

subroutine setNextLink(this,next)
  class(link)           :: this
  type(link), pointer   :: next
  this%next => next
end subroutine setNextLink

function getPrevLink(this)
  class(link)           :: this
  type(link), pointer   :: getPrevLink
  getPrevLink => this%prev
end function

subroutine setPrevLink(this,prev)
  class(link)           :: this
  type(link), pointer   :: prev
  this%prev => prev
end subroutine setPrevLink

integer function getData(this)
  class(link)           :: this
  getData = this%ldata
end function getData

function constructor(ldata, next, prev)
  class(link), pointer    :: constructor
  integer                 :: ldata
  type(link), pointer     :: next, prev

  allocate(constructor)
  constructor%next => next
  constructor%prev => prev
  constructor%ldata = ldata
end function constructor

subroutine append(this, ldata)
  class(list)             :: this
  integer                 :: ldata
  class(link), pointer    :: newLink


  if (.not. associated(this%firstLink)) then
     this%firstLink => link(ldata, null(), null())
     this%lastLink => this%firstLink
  else
     write(6,*) 'new', ldata
     newLink => link(ldata, null(), this%lastLink)
     call this%lastLink%setNextLink(newLink)
     this%lastLink => newLink
  end if

end subroutine append

integer function getFirst(this)
  class(list)           :: this
  getFirst = this%firstLink%getData()
end function getFirst

integer function getLast(this)
  class(list)           :: this
  getLast = this%lastLink%getData()
end function getLast

integer function getCurrent(this)
  class(list)           :: this
  if (.not. associated(this%currentLink)) &
     this%currentLink => this%firstLink
  getCurrent = this%currentLink%getData()
end function getCurrent

subroutine resetCurrent(this)
  class(list)           :: this
  this%currentLink => null()
end subroutine resetCurrent

integer function getNext(this)
  class(list)           :: this
  if (.not. associated(this%currentLink)) then
     this%currentLink => this%firstLink
     getNext = this%currentLink%getData()
  elseif (associated(this%currentLink%getNextLink())) then
     this%currentLink => this%currentLink%getNextLink()
     getNext = this%currentLink%getData()
  else
     error stop 'trying to go beyond last element in list'
  end if 
end function getNext

integer function getPrev(this)
  class(list)           :: this
  if (.not. associated(this%currentLink)) then
     this%currentLink => this%lastLink
     getPrev = this%currentLink%getData()
  elseif (associated(this%currentLink%getPrevLink())) then
     this%currentLink => this%currentLink%getPrevLink()
     getPrev = this%currentLink%getData()
  else
     error stop 'trying to go beyond first element in list'
  end if 
end function getPrev

end module


program test_list
  use linked_list
  implicit none

  type(list)                :: l

  call l%append(1)
  write(6,*) 'bla'
  write(6,*) l%getFirst()
  write(6,*) l%getCurrent()
  write(6,*) l%getLast()
  call l%append(2)
  write(6,*) 'bla'
  write(6,*) l%getFirst()
  write(6,*) l%getCurrent()
  write(6,*) l%getLast()
  call l%append(3)
  write(6,*) 'bla'
  write(6,*) l%getFirst()
  write(6,*) l%getCurrent()
  write(6,*) l%getLast()
  write(6,*) 'bla'
  call l%resetCurrent()
  write(6,*) l%getPrev()
  write(6,*) l%getPrev()
end program