-- Update Online Resume System with Muhamad Affindi's actual CV data
USE online_resume_system;

-- =====================================================
-- Profile
-- =====================================================
UPDATE profile SET
    full_name = 'Muhamad Affindi',
    job_title = 'IT Service Delivery (Cloud Hybrid, Windows, Linux)',
    email = 'maffindi@yahoo.com',
    phone = '(60) 172446156',
    location = 'Puchong, Selangor',
    linkedin_url = 'https://www.linkedin.com/in/maffindi/',
    website_url = 'https://github.com/fendi-321',
    profile_image = 'my_pic.jpg',
    summary = 'With more than ~13 years of working experiences in IT environment and 5 years in Cloud Operation. A key team player with relevant aptitude and positive attitude. Proactively seeking to upskill and upgrade in Information Technology field. To involve in new projects to broaden skills, knowledge and make positive contributions.'

WHERE id = 1;

-- =====================================================
-- Experiences (clear sample data, insert real work history)
-- =====================================================
DELETE FROM experiences;

INSERT INTO experiences (company_name, job_title, location, start_date, end_date, is_current, description, display_order) VALUES
('Group Avows', 'Cloud automation', NULL, '2025-12-01', NULL, 1,
 '- Spearheaded cloud automation deployment utilizing GitLab, Jenkins, GitHub, and Bitbucket to streamline CI/CD processes.\n- Implemented Infrastructure as Code (IaC) using Ansible for installations and Terraform for infrastructure management.\n- Collaborated with cross-functional teams to enhance cloud pipeline efficiency, ensuring seamless integration and deployment.', 1),

('Epicor (M) Sdn Bhd', 'Cloud Reliability Analyst', NULL, '2024-04-01', '2025-09-30', 0,
 '- Creation and maintenance of VMs for new and existing customers.\n- Monitoring performance metrics using App Insights, App Dynamics, and SolarWinds.\n- Ongoing performance tweaks to SQL configurations (refresh DB, CPU/Memory utilization).\n- Building and maintaining Azure DevOps Pipelines.\n- Utilizing PowerShell scripts and ARM templates; familiar with K9s containerization.\n- Using ServiceNow for daily operations.', 2),

('KAF Digital Bank', 'Assistant Manager IT', NULL, '2023-10-01', '2024-04-30', 0,
 '- Lead managed services team to tackle Infra and application level disruptions (e-KYC, Core Banking).\n- Ensure system/network compliance with regulatory requirements.\n- Commission and maintain operating environment for Digital banking applications.\n- Prepare KPIs for system and application performance.', 3),

('Noventiq Solution', 'Project Coordinator', NULL, '2023-01-01', '2023-09-30', 0,
 '- Managing small size projects remotely, ensuring timeline and customer satisfaction.\n- Project Risk Management (Analyze risk/Costs impact/Resources Risk).\n- Providing overall project updates to management (Bi-weekly/Monthly).', 4),

('DXC Technology', 'ITIO Cloud Service Delivery', NULL, '2019-01-01', '2022-11-30', 0,
 '- Managed nearly 10k cloud hybrid servers (VMware and AWS) for internal companies.\n- Monitoring resources and platforms such as AWS EC2 and ELB.\n- Integrate private cloud tools (HP CSA, HP OO, HPSA) to monitor server deliverance.\n- Handling incidents, changes, and requests using ServiceNow.\n- Experiencing SQL query, JSON scripting and VMware PowerCLI.', 5),

('Eastern & Oriental Berhad', 'Senior IT Exec', NULL, '2018-02-01', '2019-01-31', 0,
 '- Maintained overall infrastructure, network security, virtualization, and IT risk.\n- Implemented projects relating to infrastructure and service delivery.\n- Work closely with vendors and stakeholders to ensure project delivery.', 6),

('HPE Multimedia', 'IT Consultant II', NULL, '2013-03-01', '2017-10-31', 0,
 '- Provide Microsoft Server and VMware support for HP Enterprise Services World Wide.\n- Experience with trouble ticketing and request management tools.', 7),

('DKSH (M) Sdn Bhd', 'Windows Specialist II', NULL, '2012-05-01', '2013-03-31', 0,
 '- Knowledge of, and experience supporting, Microsoft Windows Server 2003/2008.\n- Understanding of networking, system management, VMware, Hyper-V Windows Server operating system.', 8),

('Arvato (M) Sdn Bhd', 'System Engineer', NULL, '2011-09-01', '2012-05-31', 0,
 '- Commission and maintain the operating environment of all Windows (Servers & PCs) and VMWare-based systems, including global applications.\n- Perform day-to-day operations, administration, tuning and capacity management of Windows/VMWare systems to ensure good performance.', 9),

('ACS (M) Sdn Bhd', 'Infra Mgmt Analyst', NULL, '2009-02-01', '2011-09-30', 0,
 '- Assist in any IT infrastructure Research & Development projects assigned from time to time. Involve in IT Asset Management.\n- Work closely with IT Manager and project team to provide necessary support and solution.\n- Provide IT support (including setup and maintenance of PC hardware, software application (SAP, MS Dynamics 2011), server and network-related issues).', 10);

-- =====================================================
-- Education
-- =====================================================
DELETE FROM education;

INSERT INTO education (institution, degree, field_of_study, location, start_date, end_date, display_order) VALUES
('University Putra Malaysia', 'Diploma', 'Computer Science / IT', NULL, '2001-10-01', '2005-10-31', 1);

-- =====================================================
-- Skills (Technical skills + certifications combined as skills)
-- =====================================================
DELETE FROM skills;

INSERT INTO skills (skill_name, category, proficiency_level, display_order) VALUES
('Private Cloud Hybrid', 'Cloud', 'Expert', 1),
('AWS', 'Cloud', 'Advanced', 2),
('Azure & DevOps', 'Cloud', 'Advanced', 3),
('Terraform', 'IaC', 'Advanced', 4),
('VMware / Hyper-V', 'Virtualization', 'Expert', 5),
('PowerShell', 'Scripting', 'Advanced', 6),
('SQL Query', 'Database', 'Intermediate', 7),
('System Center', 'Tools', 'Advanced', 8),
('HP CSA/HPSA', 'Tools', 'Advanced', 9);

-- =====================================================
-- Certifications
-- =====================================================
DELETE FROM certifications;

INSERT INTO certifications (cert_name, issuing_org, issue_date, display_order) VALUES
('AWS Cloud Practitioner', 'Amazon Web Services', NULL, 1),
('AWS SysOps Associate', 'Amazon Web Services', NULL, 2),
('MCP 2000 / MCSA / MCSE', 'Microsoft', NULL, 3),
('Azure Fundamentals', 'Microsoft', NULL, 4),
('Azure Administrator Associate', 'Microsoft', NULL, 5),
('ITIL Foundation V2 / V3', 'ITIL', NULL, 6),
('Terraform Associate', 'HashiCorp', NULL, 7),
('PMP Certification', 'PMI', NULL, 8),
('ISC2', 'ISC2', NULL, 9);

-- =====================================================
-- Projects (Key Projects from CV)
-- =====================================================
DELETE FROM projects;

INSERT INTO projects (project_name, description, technologies_used, project_url, start_date, end_date, display_order) VALUES
('KAF Digital Bank - DR & Validation', 'Disaster Recovery Readiness, Health Check Phase 2/3, Network validation, and Core Banking SIT & UAT.', 'Disaster Recovery, Banking', NULL, NULL, NULL, 1),
('HGB - Google to O365 Migration', 'Managed scheduling from kickoff to UAT, admin training, solution architect review, and validation.', 'Migration, O365', NULL, NULL, NULL, 2),
('BSN - DR Activity', 'Involved with vendor sign-off (VSTEC, BlueFortress) and scheduling with Platform, DB, and App teams.', 'Vendor Mgmt, Coordination', NULL, NULL, NULL, 3),
('E&O - Migrate to HCI (VSAN)', 'Migrated physical old servers to HCI (HPE Gen9), P2V involvement, Network Trunking, and UAT Validation.', 'Virtualization, HPE', NULL, NULL, NULL, 4);
