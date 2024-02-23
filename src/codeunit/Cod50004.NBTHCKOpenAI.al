codeunit 50004 "NBT HCK OpenAI"
{
    TableNo = "NBT HCK Log";

    trigger OnRun()
    begin
        Process(rec);
        ;
    end;

    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        EnvironmentInformation: Codeunit "Environment Information";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";

    procedure Process(var rec: record "NBT HCK Log")
    var
        setup: Record "NBT HCK Setup";
        result: Text;
    begin

        setup.get;
        case rec.Type of
            rec.type::Context:
                begin
                    ProcessOpenAI(rec, setup."AOAI contextprompt");
                end;
            rec.type::ParseQuote:
                begin
                    ProcessOpenAI(rec, setup."AOAI parseQuoteprompt");
                end;
            rec.type::Customer:
                begin
                    ProcessOpenAI(rec, setup."AOAI getcustomernoprompt");
                end;
            rec.type::Item:
                begin
                    ProcessOpenAI(rec, setup."AOAI getitemprompt");
                end;
            rec.type::ParseCustomer:
                begin
                    ProcessOpenAI(rec, setup."AOAI parsecustomerprompt");
                end;

            else
                ERROR('INVALID');
        end;

    end;

    procedure ProcessOpenAI(var rec: record "NBT HCK Log"; sys: Text) Result: Text;
    var
        setup: Record "NBT HCK Setup";

    begin
        setup.get;
        AzureOpenAI.SetAuthorization(setup."AOAI Model Type", setup."AOAI Endpoint", setup."AOAI Deployment", setup.GetAPIKEY());

        AOAIChatCompletionParams.SetMaxTokens(setup."AOAI MaxToken");
        AOAIChatCompletionParams.SetTemperature(setup."AOAI Temperature");


        AzureOpenAI.SetCopilotCapability(rec.Type);

        AOAIChatMessages.AddUserMessage(rec.GetInput());
        AOAIChatMessages.AddSystemMessage(sys);
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then begin
            Result := AOAIChatMessages.GetLastMessage();
            Result := Result.Replace('<__user_output__>', '');
            Result := Result.Replace('</__user_output__>', '');
            Result := Result.Replace('<__user_input__>', '');
            Result := Result.Replace('</__user_input__>', '');
            Result := Result.Replace('</__output__>', '');
            Result := Result.Replace('<__output__>', '');

            Result := Result.Replace('<__solution__>', '');
            Result := Result.Replace('</__solution__>', '');

            Result := Result.Replace('<__model_response__>', '');
            Result := Result.Replace('</__model_response__>', '');
            Result := Result.Replace('<__model_output__>', '');
            Result := Result.Replace('</__model_output__>', '');

            Result := Result.Replace('\n', '');

            Result := Result.Replace('/n', '');
            rec.SetOutput(Result);
            rec.Modify();
            rec.Processed := CurrentDateTime;
            rec.Status := 'Processed';
            rec.Modify();

        end else begin
            Error(AOAIOperationResponse.GetError());
        end;
    end;
}
