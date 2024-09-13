import ballerina/http;
import ballerina/time;


public type Program record {|
    readonly string program_code;
    int nqf_level;
    string faculty;
    string department;
    string title;
    time:Utc registration_date;
    Course[] courses;
|};

public type Course record {|
    readonly string course_Code;
    string course_name;
    int nqf_level;
|};

type ErrorDetail record {
    string message;
};

type ProgramNotFound record {|
    *http:NotFound;
    ErrorDetail body;
|};

type CourseNotFound record {|
    *http:NotFound;
|};

type ErrorMsg record {|
    string errmsg;
|};

type AlreadyExistsError record {|
    *http:Conflict;
    ErrorMsg body;
|};

// Define the tables
table<Course> key(course_Code) courses = table [
    {course_Code: "WAS621S", course_name: "Web Application Security", nqf_level: 7},
    {course_Code: "DSA621S", course_name: "Distributed Systems Applications", nqf_level: 7}
];

table<Program> key(program_code) programs = table [];

// Define the service

service /programs on new http:Listener(8080) {

    // private int counter;
    // private Program[] programs;

    // function init() {
    //     self.programs = [];
    //     self.counter = 0;
    // }

    resource function POST programs(@http:Payload Program[] newProgram) returns Program[]|AlreadyExistsError {

        string[] alreadyExists = from Program programEntry in newProgram
            where programs.hasKey(programEntry.program_code)
            select programEntry.program_code.toString();

        // Validate the input
        if alreadyExists.length() > 0 {
            return {
                body: {
                        errmsg: string:'join(" ", ...alreadyExists)
                    }
            };
        }else{
            newProgram.forEach(programEntry => programs.add(programEntry));
            return newProgram;
        }

    }

    resource function get programs() returns Program[] | error {
        return programs.toArray(); 
    }
}