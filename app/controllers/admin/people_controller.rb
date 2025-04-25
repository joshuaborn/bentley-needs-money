class Admin::PeopleController < ApplicationController
  def index
    if current_person.administrator?
      @people = Person.left_outer_joins(:connections).distinct.
        select("people.*, COUNT(connections.*) AS connections_count").
        group("people.id").order(created_at: :desc)
    else
      redirect_to root_path
    end
  end
end
