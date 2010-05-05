subject_klass = Struct.new('Subject', :name, :code, :weekly_hours)

subjects = [
  subject_klass.new('English', 'S001', 10),
  subject_klass.new('Maths', 'S002', 10),
  subject_klass.new('Physics', 'S003', 5),
  subject_klass.new('Chemistry', 'S004', 5),
  subject_klass.new('Chinese', 'S005', 10),
]

$context = {
  :_pictures => {
    :staff_signature  =>  $data_file['staff_signature.gif'],
    :school_logo  =>  $data_file['school_logo.jpg'],
  },
  :subjects => subjects,
  :admin_staff_email => "admin@demo.com",
  :student_address_line_3 => "Jupiter 04771-0130",
  :school_website => "www.wizardcollege.edu",
  :student_nric => "S667755161",
  :course_start_date => "Jan 1, 2010",
  :serial_number => "00000026",
  :student_full_name => "Kok Yeow Loh",
  :school_name => "Wizard College",
  :course_name => "2 Yr 'O' Level",
  :school_address_line_1 => "2985 Jalan Timum",
  :total_weekly_hours => subjects.inject(0) {|sum, s| sum + s.weekly_hours },
  :student_first_name => "Kok Yeow",
  :school_telephone => "+65 6511 6833",
  :date_of_offer => "May 5, 2010",
  :course_intake => "Jan Intake",
  :school_address_line_2 => "XYZ Learning Centre",
  :examination_authority => "UNDEFINED(examination_authority)",
  :student_address_line_1 => "Blk 151",
  :school_fax => "+65 6511 6844",
  :admin_staff_name => "Tan Tze Wei",
  :school_address_line_3 => "Jupiter 159457",
  :course_duration => "24 months",
  :student_address_line_2 => "5921 Albert Village",
  :school_email => "info@wizardcollege.edu.sg",
}
