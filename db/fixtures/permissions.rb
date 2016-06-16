ROLE_ID = {
  admin: 1,
  writer: 2,
  participant: 3,
  viewer: 4,
  nobody: 5,
}

PERMIT_ALL = ""
FORBID_ALL = "0"

def def_perm(resource, role, methods, action: "", query: nil, parameters: nil, join: "")
  methods = [methods] if not methods.is_a? Array

  methods.each do |method|
    Permission.seed do |p|
      p.resource   = resource.to_s.downcase.pluralize
      p.action     = action.to_s
      p.method     = method.to_s.upcase
      p.query      = query
      p.parameters = parameters
      p.join       = join
      p.role_id    = ROLE_ID[role]
    end
  end
end

def permit(resource, role, methods, **option)
  def_perm(resource, role, methods, query: PERMIT_ALL, **option)
end

def forbid(resource, role, methods, **option)
  def_perm(resource, role, methods, query: FORBID_ALL, **option)
end

%i(admin writer participant viewer).each do |role|
  permit(Member, role, %i(GET), action: :members_me)
end

%i(writer participant viewer).each do |role|
  permit(Team, role, %i(GET))
  permit(Comment, role, %i(GET), action: :problems_comments)
end

# Admin

%i(Member Team Score Problem Issue Answer).each do |resource|
  permit(resource, :admin, %i(GET POST PUT PATCH DELETE))
end

%i(Problem Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"
  permit(resource, :admin, %i(GET), action: action)
  permit(Comment,  :admin, %i(POST PUT PATCH DELETE), action: action)
end


# Writer

permit(Team,    :writer, %i(POST PUT PATCH DELETE))
permit(Problem, :writer, %i(GET POST))
permit(Issue,   :writer, %i(GET POST PUT PATCH DELETE))
permit(Answer,  :writer, %i(GET POST PUT PATCH DELETE))
permit(Score,   :writer, %i(GET POST))
permit(Comment, :writer, %i(GET POST PUT PATCH DELETE), action: :issues_comments)
permit(Comment, :writer, %i(GET), action: :answers_comments)
permit(Comment, :writer, %i(POST PUT PATCH DELETE), action: :answers_comments)

def_perm(Member, :writer, %i(GET POST PUT PATCH DELETE),
  query: "roles.rank >= :rank",
  parameters: "{ rank: role.rank }",
  join: "role")

def_perm(Member, :writer, %i(GET POST PUT PATCH DELETE),
  query: "roles.rank >= :rank",
  parameters: "{ rank: role.rank }",
  join: "role")

def_perm(Problem, :writer, %i(PUT PATCH DELETE),
  query: "creator_id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Problem, :writer, %i(POST),
  action: :problems_comments,
  query: "creator_id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Comment, :writer, %i(PUT PATCH DELETE),
  action: :problems_comments,
  query: "member_id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Score, :writer, %i(PUT PATCH DELETE),
  query: "marker_id = :id",
  parameters: "{ id: current_user.id }")

# Participant

forbid(Member,  :participant, %i(GET POST DELETE))
forbid(Team,    :participant, %i(POST PUT PATCH DELETE))
forbid(Problem, :participant, %i(POST PUT PATCH DELETE))
permit(Issue,   :participant, %i(POST))
forbid(Issue,   :participant, %i(DELETE))
permit(Answer,  :participant, %i(POST))
forbid(Answer,  :participant, %i(DELETE))
forbid(Score,   :participant, %i(GET POST PUT PATCH DELETE))
forbid(Problem, :participant, %i(POST), action: "problems_comments")
forbid(Comment, :participant, %i(PUT PATCH DELETE), action: "problems_comments")
forbid(Comment, :participant, %i(DELETE), action: "issues_comments")
forbid(Comment, :participant, %i(DELETE), action: "answers_comments")

def_perm(Member, :participant, %i(PUT PATCH),
  query: "id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Problem, :participant, %i(GET),
  query: "opened_at <= :now AND :now <= closed_at",
  parameters: "{ now: DateTime.now }")

def_perm(Issue, :participant, %i(GET PUT PATCH),
  query: "team_id = :team_id",
  parameters: "{ team_id: current_user.team_id }")

def_perm(Answer, :participant, %i(GET PUT PATCH),
  query: "team_id = :team_id",
  parameters: "{ team_id: current_user.team_id }")

%i(Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"

  def_perm(resource, :participant, %i(POST),
    action: action,
    query: "team_id = :team_id",
    parameters: "{ team_id: current_user.team_id }")

  def_perm(Comment, :participant, %i(GET PUT PATCH),
    action: action,
    query: "members.team_id = :team_id",
    parameters: "{ team_id: current_user.team_id }",
    join: "member")
end

# Viewer

def_perm(Member, :viewer, %i(GET),
  query: "roles.rank >= :rank",
  parameters: "{ rank: role.rank }",
  join: "role")

%i(Problem Score Issue Answer).each do |resource|
  permit(resource, :viewer, %i(GET))
end

%i(Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"
  permit(Comment, :viewer, %i(GET), action: action)
end

%i(Member Team Score Problem Issue Answer).each do |resource|
  forbid(resource, :viewer, %i(POST PUT PATCH DELETE))
end

%i(Problem Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"
  forbid(resource, :viewer, %i(POST), action: action)
  forbid(Comment,  :viewer, %i(PUT PATCH DELETE), action: action)
end
