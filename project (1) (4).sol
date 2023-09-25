// SPDX-License-Identifier: MIT


pragma solidity >=0.8.2 <0.9.0;

contract project {
    
    address[] admins;
    address[] patient_address;
    address[] clinic_address;
    address[] doctor_address;


    struct visit
    {
        address doctor;
        string date;
        string diagnosis;
        string medicine_prescribed;
    }

    struct test
    {
        address doctor;
        string date;
        string tests;
    }

    struct clinic
    {
        string name;
        string location;
        uint256 pincode;
    }

    struct patient
    {
        string name;
        uint256 age;
        string number;  //something like aadhar number
    }
    struct doctor
    {
        string name;
        uint256 age;
        string qualification;
        uint256 number;
    }

  // this is basically to get the details...for the user to see....
    mapping(address => patient) private patients;
    mapping(address => clinic) private clinics;
    mapping(address => doctor) private doctors;

    mapping(address => address[]) private my_doctors; //this is patient doctor mapping 
    mapping(address => visit[]) private my_visits;
    mapping(address => address[]) private my_clinics;
    mapping(address => test[]) private my_tests;
    mapping(address => string[] ) private my_results;



    constructor() {
        admins.push(msg.sender); // Push the creator of the contract as the first admin
    }

    ////////////////////////////////////////////////////// Modifier to check the sender validity all modifiers are present
    modifier isAdmin() {
        bool flag = false;

        for (uint256 i = 0; i < admins.length; i++) {
            if (msg.sender == admins[i]) {
                flag = true;
                break;
            }
        }

        require(flag==true, "Caller is not one of the admins");
        _;
    }

    modifier isPatient() {
        bool flag=false;
        for(uint256 i = 0; i < patient_address.length; i++) {
            if (msg.sender == patient_address[i]) {
                flag = true;
                break;
            }
        }

        require(flag==true, "you have to first become a patient first(addPatient) then you can access this feature");
        _;

    }

    modifier isDoctor() {
        bool flag=false;
        for(uint256 i = 0; i < doctor_address.length; i++) {
            if (msg.sender == doctor_address[i]) {
                flag = true;
                break;
            }
        }

        require(flag==true, "you have to first become a doctor first(addDoctor) then you can access this feature");
        _;

    }

    modifier isClinic() {
        bool flag=false;
        for(uint256 i = 0; i < clinic_address.length; i++) {
            if (msg.sender == clinic_address[i]) {
                flag = true;
                break;
            }
        }

        require(flag==true, "you have to first become certified clinic (addClinic) then you can access this feature");
        _;

    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function is_he_doctor(address d) private view returns(bool)
    {
        bool flag=false;
        for(uint256 i = 0; i < doctor_address.length; i++) {
            if (d == doctor_address[i]) {
                flag = true;
                break;
            }
        }

        return flag;
        
    }

    function is_he_patient(address d) private view returns(bool)
    {
        bool flag=false;
        for(uint256 i = 0; i < patient_address.length; i++) {
            if (d == patient_address[i]) {
                flag = true;
                break;
            }
        }

        return flag;
        
    }

    function you_are_his_doctor(address doc,address pat) private view returns(bool)
    {
        bool flag=false;
        for(uint256 i=0;i<my_doctors[pat].length; i++)
        {
            if(doc==my_doctors[pat][i])
            {
                flag=true;
                break;
            }
        }

        return flag;
    }

    function is_this_clinic(address d) private view returns(bool)
    {
        bool flag=false;
        for(uint256 i = 0; i < clinic_address.length; i++) {
            if (d == clinic_address[i]) {
                flag = true;
                break;
            }
        }

        return flag;
        
    } 

    function you_are_the_clinic(address pat,address here_clinic) private view returns(bool)
    {
        bool flag=false;
        for(uint256 i=0;i<my_clinics[pat].length; i++)
        {
            if(here_clinic==my_clinics[pat][i])
            {
                flag=true;
                break;
            }
        }

        return flag;
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function addAdmin(address new_admin) public isAdmin {
        admins.push(new_admin);
    }

    function getAdmins() public isAdmin view returns (address[] memory) {
        return admins;
    }

    //this is where patient can add her details into the blockchain.....using this function

    function addPatient(string memory name,uint256 age,string memory number) public payable 
    {
        require(msg.value >= 1000000000000000000,"sorry atleast 1 ether is required to become a member of the EHR system");

        require(is_he_patient(msg.sender)==false,"you are already a registered patient");

        patient memory p = patient(name, age, number);

        patients[msg.sender]=p;

        patient_address.push(msg.sender);


        address payable admin1 = payable(admins[0]);  // Convert to payable address admin 0 is the founder so...
        admin1.transfer(msg.value);

    }

    function getPatients() public isAdmin view returns (address[] memory) {
        return patient_address;
    }

    function addClinic(string memory name,string memory location,uint256 pin) public payable 
    {
        require(msg.value >= 1000000000000000000,"sorry atleast 1 ether is required to become a member of the EHR system");

        require(is_this_clinic(msg.sender)==false,"you are already a clinic");

        clinic memory c=clinic(name,location,pin);

        clinics[msg.sender]=c;   //mapping is done here...

        clinic_address.push(msg.sender);

        address payable admin1 = payable(admins[0]);  //Convert to payable address admin0 is the founder so he gets the money
        admin1.transfer(msg.value);
    }

    function getClinics() public isAdmin view returns (address[] memory) {
        return clinic_address;
    }

    function addDoctor(string memory name,uint256 age,string memory qualification,uint256 number) public payable 
    {
        require(msg.value >= 1000000000000000000,"sorry atleast 1 ether is required to become a member of the EHR system");

        require(is_he_doctor(msg.sender)==false,"sorry you are already a registered doctor..");

        doctor memory d = doctor(name, age, qualification,number);

        doctors[msg.sender]=d;

        doctor_address.push(msg.sender);

        address payable admin1 = payable(admins[0]);  // Convert to payable address admin 0 is the founder so...
        admin1.transfer(msg.value);

    }

    function getDoctors() public isAdmin view returns (address[] memory) {
        return doctor_address;
    }


    function add_my_doctors(address mydoc) public isPatient 
    {

        require(is_he_doctor(mydoc)==true,"sorry your doctor is not under our system tell him to register");
        my_doctors[msg.sender].push(mydoc);
    }

    function get_my_doctors() public view  isPatient returns (address[] memory)
    {
        require(my_doctors[msg.sender].length>0,"sorry you dont have any doctor");

        return my_doctors[msg.sender];
    }

    function diagnosis(address pat,string memory date,string memory here_diagnosis,string memory test_here,string memory tablets) public isDoctor
    {
        require(is_he_patient(pat)==true,"sorry your patient is not under our system tell him to register");

        require(you_are_his_doctor(msg.sender, pat)==true,"you are not his doctor tell your patient to register you as his doctor");

        visit memory v=visit(msg.sender,date,here_diagnosis,tablets);

        if((keccak256(bytes(test_here)) != keccak256(bytes("none"))))
        {
            test memory t=test(msg.sender,date,test_here);
            my_tests[pat].push(t);
        }

        my_visits[pat].push(v);
    }

    function view_my_visits() public view isPatient returns(visit[] memory )
    {
        require(my_visits[msg.sender].length>0,"sorry you dont have any visits");
        return my_visits[msg.sender];
    }

    function view_my_tests() public view isPatient returns (test[] memory)
    {
        require(my_tests[msg.sender].length>0,"sorry you dont have any test ");

        return my_tests[msg.sender];
    }


    function add_my_clinics(address my_clinic) public isPatient
    {
        require(is_this_clinic(my_clinic)==true,"sorry the clinic is not registered...");

        my_clinics[msg.sender].push(my_clinic);

    }

    function view_my_clinics() public view isPatient returns (address[] memory)
    {
        require(my_clinics[msg.sender].length>0,"sorry you dont have any clinics...");
        return my_clinics[msg.sender];

    }

    function view_tests(address pat) public view isClinic returns (test[] memory)
    {
        require(you_are_the_clinic(pat,msg.sender)==true,"sorry you are not the patients clinic tell your patient to add you first");

        require(is_he_patient(pat)==true,"sorry your patient is not under our system tell him to register");

        require(my_tests[pat].length>0,"sorry the patients does have any test");

        return my_tests[pat];


    }

    function test_result(address pat,string memory result) public isClinic
    {
        require(you_are_the_clinic(pat,msg.sender)==true,"sorry you are not the patients clinic tell your patient to add you first");

        require(my_tests[pat].length>0,"sorry the patient does not have any tests yet");

        my_results[pat].push(result);

    }

    function view_my_test_result() public view isPatient returns (string[] memory)
    {
        require(my_results[msg.sender].length>0,"you dont have any results");

        return my_results[msg.sender];
    }

    function doctor_result_check(address pat) public view isDoctor returns (string[] memory)
    {
        require(you_are_his_doctor(msg.sender, pat)==true,"you are not his doctor tell your patient to register you as his doctor");

        require(my_tests[pat].length>0,"sorry no test has been assigned yet");

        require(my_results[pat].length>0,"sorry there are no results yet");

        return my_results[pat];
    }

}








    






