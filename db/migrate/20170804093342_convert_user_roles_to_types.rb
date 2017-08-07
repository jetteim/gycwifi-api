class ConvertUserRolesToTypes < ActiveRecord::Migration[5.0]
  ROLES =
    {
      'FreeUser'      => 0,
      'ProUser'       => 1,
      'ExclusiveUser' => 2,
      'AdminUser'     => 3,
      'EngineerUser'  => 4,
      'AgentUser'     => 5,
      'EmployeeUser'  => 6,
      'OperatorUser'  => 7,
      'ManagerUser'   => 8
    }.freeze

  def up
    User.inheritance_column = nil
    change_column :users, :role_cd, :string
    rename_column :users, :role_cd, :type
    change_column_default :users, :type, 'FreeUser'
    User.reset_column_information

    ROLES.each do |role_name, role_id|
      User.where(type: role_id).update_all(type: role_name)
    end
  end

  def down
    User.inheritance_column = nil

    ROLES.each do |role_name, role_id|
      User.where(type: role_name).update_all(type: role_id)
    end

    change_column_default :users, :type, nil
    execute 'ALTER TABLE "users" ALTER COLUMN "type" TYPE integer ' \
      'USING type::integer'
    rename_column :users, :type, :role_cd
    change_column_default :users, :role_cd, 0
  end
end
