unit uBankOperations;

interface
uses
  Classes, SysUtils, Generics.Collections;
  type
      {General Notes:
        This project built with Delphi 10.3 community edition and DUnitX. This uses Custom Exceptions, Enumerated Data Types, Interfaces, Classes,
        Inheritance of Interfaces and classes, Virtual Methods, Overriding a Virtual Method, Reintroducing a Virtual Method, Constructor, Destructor,
        Properties etc. Please note most of the classes are TInterfacedObject types, so automatically handles the reference counting and memory
        management of interfaced objects. Also, ReportMemoryLeaksOnShutdown flag is used to report memory leaks when running from debug mode.
        Added IsConsole flag to "False" to work this properly in a console application. "TestBankOperations.dpr" peoject will hold the testing
        of unit uBankOperations.pas. Since the main expectation of the project, is  uBankOperations.pas  and uTestBankOperations.pas, the actual
        project "BankOperations.dpr" might not function as a console application to use objects from "uBankOperations.pas".
       }
    //Custom Exceptions
      {Exceptions for the method TBankOperations.CreateAccount.}
      ECreateAccountException = class(Exception);
      {Exceptions for the method TBankOperations.Deposit.}
      EDepositException = class(Exception);
      {Exceptions for the method TBankOperations.Withdraw.}
      EWithdrawException = class(Exception);
      {Exceptions for the method TBankOperations.MiniStatement.}
      EMiniStatementException = class(Exception);

    //Enumerated Types
      {TTransactionType Shows which type the transaction is, is it Deposit or Withdraw. TTransactionType used in ITransaction.}
      TTransactionType = (ttDeposit, ttWithdraw);
      {TBankAccountType Shows which type of account is, Savings Account or Current Account. TBankAccountType used in IBankAccount.}
      TBankAccountType = (batSavings, batCurrent);

    //Interfaces
      {Interface for TPerson class and handles details of the customer like Name and mobile}
      IPerson = interface
        function GetName:string;
        function GetMobileNumber:string;
        property Name:string read GetName;
        property Mobile:string read GetMobileNumber;
      end;
      {Interface for TTransaction class and handles details of the Transaction like Date, Amount, and Transaction Type (Deposit or Withdraw).}
      ITransaction = interface
        function GetAmount: Currency;
        function GetDate:TDateTime;
        function GetTransactionType: TTransactionType;
        property Date:TDateTime read GetDate;
        property Amount: Currency read GetAmount;
        property TransactionType: TTransactionType read GetTransactionType;
      end;
      {Interface for TAccount class and handles basic details of the Account like customer, Account number, Balance.}
      IAccount = interface
        function GetCustomer: IPerson;
        function GetAccountNumber: string;
        function GetBalance:Currency;
        property Customer:IPerson read GetCustomer;
        property AccountNumber:string read GetAccountNumber;
        property Balance:Currency read GetBalance;
      end;
      {Interface for TBankAccount class and handles details of the Bank Account like Bank Account Type, List of Transactions, etc. Also, this
        interface is inherited from IAccount so it will hold the functionalities of IAccount too. }
      IBankAccount = interface (iAccount)
        procedure AddTransaction(const Transaction: ITransaction);
        function GetTransactions: TList<ITransaction>;
        function GetBankAccountType: TBankAccountType;
        property Transactions: TList<ITransaction> read GetTransactions;
        property BankAccountType: TBankAccountType read GetBankAccountType;
      end;
      {IBankOperations is the main interface that handles all the main operations of the Bank like CreateAccount, Deposit, Withdraw, MiniStatement.
        Also added Total Balance property and Account method for easy comparison of values.}
      IBankOperations = interface(IInterface)
        function CreateAccount(const AccountHolderName:string; const MobileNumber:string; const BankAccountType: TBankAccountType):string;
        procedure Deposit(const AccountNumber:string; const Amount: Currency; const DateAndTime:TDateTime);
        procedure Withdraw(const AccountNumber:string; const Amount: Currency; const DateAndTime:TDateTime);
        function MiniStatement(const AccountNumber: string):TStrings;

        function ReadTotalBalance: Currency;
        property TotalBalance:Currency read ReadTotalBalance;
        function Account(const AccountNumber:string):IBankAccount ;
      end;

    //Classes
      {TPerson class implements IPerson interface and holds details of the customer like Name and mobile. Name and Mobile are read-only properties set
        from the constructor.}
      TPerson = class(TInterfacedObject, IPerson)
        strict private
          FCustomerName:string;
          FMobileNumber:string;
          function GetName:string;
          function GetMobileNumber:string;
        public
          constructor Create(const CustomerName:string; const MobileNumber:string);
          property Name:string read GetName;
          property Mobile:string read GetMobileNumber;
      end;
      {TTransaction class implements ITransaction interface and holds details of the Transaction Date, Amount, and Transaction Type (Deposit or Withdraw).
        Date, Amount, and Transaction Type are read-only properties set from the constructor.}
      TTransaction = class (TInterfacedObject, ITransaction)
        strict private
          FAmount: Currency;
          FDate: TDateTime;
          FTransactionType: TTransactionType;
          function GetAmount: Currency;
          function GetDate: TDateTime;
          function GetTransactionType: TTransactionType;
        public
          constructor Create(Amount: Currency; Date: TDateTime; TransactionType: TTransactionType);
          property Date:TDateTime read GetDate;
          property Amount: Currency read GetAmount;
          property TransactionType: TTransactionType read GetTransactionType;
      end;
      {TAccount class implements IAccount interface and hold basic details of the Account like customer, Account number, Balance. Added methods GetAccountNumber
        and GetBalance to virtual so that they can be able to override or replace via reintroduce. For the visibility made them to the private section.}
      TAccount = class(TInterfacedObject, IAccount)
        strict private
          FCustomer: IPerson;
          FAccountNumber:string;
          function GetCustomer: IPerson;
        private
          function GetAccountNumber: string; virtual;
          function GetBalance:Currency; virtual;
        public
          constructor Create(const Customer:string; const MobileNumber:string; const AccountNumber:string);
          destructor Destroy; override;
          property Customer:IPerson read GetCustomer;
          property AccountNumber:string read GetAccountNumber;
          property Balance:Currency read GetBalance;
      end;
      {TBankAccount implements IBankAccount interface and holds details of the Bank Account like Bank Account Type, List of Transactions etc. TBankAccount is
        inherited from TAccount class, it can hold the functionality of TAccount too. Method GetAccountNumber is overridden in this class and added validation.
        However, GetBalance method is hidden via reintroduce and gave a new functionality.}
      TBankAccount = class(TAccount, IBankAccount)
        strict private
          FBankAccountType: TBankAccountType;
          FTransactions: TList<ITransaction>;
          function GetBankAccountType: TBankAccountType;
          function GetTransactions: TList<ITransaction>;
          function GetAccountNumber: string; Override;
          function GetBalance:Currency; reintroduce;
        public
          constructor Create(const Customer:string; const MobileNumber:string; const BankAccountType: TBankAccountType; const AccountNumber:string);
          destructor Destroy; override;
          property Transactions: TList<ITransaction> read GetTransactions;
          property BankAccountType: TBankAccountType read GetBankAccountType;
          procedure AddTransaction(const Transaction: ITransaction);
      end;
      {TBankOperations is the main class of the project and it implements IBankOperations interface and holds all the main operations of the Bank like CreateAccount,
        Deposit, Withdraw, MiniStatement. Also added Total Balance read-only property and Account method.
        Special note about method MiniStatement, which returns TStrings considered for Text output. This can be saved to file, however, the save to file did not added for now.
        Method FindBankAccount used to search for an account by Account number and CreateStatement method used to create TStrings data. Method ValidateStrings used to
        empty check for multiple string values.}
      TBankOperations = class(TInterfacedObject, IBankOperations)
        strict private
          BankAccounts: TList<IBankAccount>;
          LastUsedAccountNumber:Integer;
          function FindBankAccount(const AccountNumber:string):IBankAccount;
          procedure CreateStatement(var Result: TStrings; BankAccount: IBankAccount);
          function ValidateStrings(const Strings: array of string) :boolean;
          function ReadTotalBalance: Currency;
        public
          constructor Create();
          destructor Destroy(); override;
          function CreateAccount(const AccountHolderName:string; const MobileNumber:string; const BankAccountType: TBankAccountType):string;
          procedure Deposit(const AccountNumber:string; const Amount: Currency; const DateAndTime:TDateTime);
          procedure Withdraw(const AccountNumber:string; const Amount: Currency; const DateAndTime:TDateTime);
          function MiniStatement(const AccountNumber: string):TStrings;
          function Account(const AccountNumber:string):IBankAccount ;
          property TotalBalance:Currency read ReadTotalBalance;
      end;

implementation
uses
  StrUtils;

const
  InitialAccountNumber = 1000001;

resourcestring
  //Exception
  sCeInvalidAccountHolderDetails = 'CreateAccount command failed due to an invalid account holder details!';
  sCeInvalidAccountNumber = 'CreateAccount command failed due to an invalid account number!';
  sCeAccountCreationFailed = 'CreateAccount command for customer %0:s  and account number %1:s is failed due to an error!';
  sAccountNotFound =  'Account with number %0:s not found!';
  sDeInvalidAmount = 'Deposit failed due to invalid amount!';
  sDeInvalidAccountNumber = 'Deposit failed due to account with number %0:s is not exists!';
  sWeInvalidAmount = 'Withdraw failed due to invalid amount!';
  sWeInvalidAccountNumber = 'Withdraw failed due to account with number %0:s is not exists!';
  sWeExceededAmount = 'Withdraw failed due to account with number %0:s do not have sufficient balance!';
  sMeInvalidAccountNumber = 'Mini statement failed due to account with number %0:s is not exists!';

{ TBankOperations }

function TBankOperations.Account(const AccountNumber: string): IBankAccount;
begin
  Result:= nil;
  if not AccountNumber.IsEmpty then
  begin
    Result:= FindBankAccount(AccountNumber);
  end;
  if not Assigned(Result) then
  begin
    raise Exception.Create(Format( sAccountNotFound, [AccountNumber]));
  end;
end;

constructor TBankOperations.Create;
begin
  inherited;
  BankAccounts:= TList<IBankAccount>.create;
  LastUsedAccountNumber:= InitialAccountNumber;
end;

function TBankOperations.CreateAccount(const AccountHolderName: string; const MobileNumber:string; const BankAccountType: TBankAccountType): string;
var
  BankAccount:IBankAccount;
begin
  Result:= EmptyStr;
  if not ValidateStrings([AccountHolderName, MobileNumber]) then
  begin
    raise ECreateAccountException.Create(sceInvalidAccountHolderDetails);
  end
  else
  begin
    Inc( LastUsedAccountNumber);
    BankAccount:= TBankAccount.Create(AccountHolderName, MobileNumber, BankAccountType, IntToStr(LastUsedAccountNumber));
    if not Assigned(BankAccount) then
    begin
      raise ECreateAccountException.Create(Format(sceAccountCreationFailed, [ AccountHolderName, IntToStr(LastUsedAccountNumber)]));
    end
    else
    begin
      Result:= BankAccount.AccountNumber;
      BankAccounts.Add(BankAccount);
    end;
  end;
end;

procedure TBankOperations.Deposit(const AccountNumber: string;
  const Amount: Currency; const DateAndTime: TDateTime);
var
  BankAccount:IBankAccount;
  Deposit:ITransaction;
begin
  if (Amount > 0) then
  begin
    BankAccount:= FindBankAccount(AccountNumber);
    if Assigned(BankAccount) then
    begin
      Deposit:=TTransaction.Create(Amount, DateAndTime, ttDeposit);
      BankAccount.AddTransaction(Deposit);
    end
    else
    begin
      raise EDepositException.Create(Format(sDeInvalidAccountNumber, [AccountNumber]));
    end;
  end
  else
  begin
    raise EDepositException.Create(sDeInvalidAmount);
  end;

end;

destructor TBankOperations.Destroy;
begin
  FreeAndNil(BankAccounts);
  inherited;
end;

function TBankOperations.FindBankAccount(const AccountNumber: string): IBankAccount;
var
  BankAccount: IBankAccount;
begin
  Result:= nil;
  for BankAccount in BankAccounts do
  begin
    if MatchText(BankAccount.AccountNumber, [AccountNumber])  then
    begin
      Result:= BankAccount;
      Break;
    end;
  end;
end;

procedure TBankOperations.CreateStatement(var Result: TStrings; BankAccount: IBankAccount);
var
  Transaction: ITransaction;
begin
  Result.Add(Format('AccountNumber: %s', [BankAccount.AccountNumber]));
  Result.Add(Format('Customer Name: %s', [BankAccount.Customer.Name]));
  Result.Add('--------------------------------------------------');
  Result.Add('Date               Amount       Type ');
  Result.Add('--------------------------------------------------');
  for Transaction in BankAccount.Transactions do
  begin
    Result.Add(Format('%0:s    %1:s        %2:s  ', [FormatDateTime('DD-MM-YYYY HH:MM:SS', Transaction.Date), CurrToStr(Transaction.Amount), IfThen(Transaction.TransactionType = ttDeposit, 'Cr', 'Dr')]));
  end;
  Result.Add('--------------------------------------------------');
  Result.Add(Format('Account Balance: %s', [CurrToStr(BankAccount.Balance)]));
  Result.Add('--------------------------------------------------');
end;

function TBankOperations.MiniStatement(const AccountNumber: string): TStrings;
var
  BankAccount: IBankAccount;
begin
  Result:= nil;
  BankAccount:= FindBankAccount(AccountNumber);
  if not Assigned(BankAccount) then
  begin
    raise EMiniStatementException.Create(Format( sMeInvalidAccountNumber, [AccountNumber]));
  end
  else
  begin
    Result:= TStringList.Create;
    CreateStatement(Result, BankAccount);
  end;
end;

function TBankOperations.ReadTotalBalance: Currency;
var
  BankAccount:IBankAccount;
begin
  Result:= 0;
  for BankAccount in BankAccounts do
  begin
    Result:= Result + BankAccount.Balance;  
  end; 
end;

function TBankOperations.ValidateStrings(const Strings: array of String): boolean;
var
  Str: string;
begin
  Result:= False;
  for Str in Strings do
  begin
    if Str.IsEmpty then
    begin
      Result:= False;
      Exit;
    end
    else
    begin
      Result:= True;
    end;
  end;
end;

procedure TBankOperations.Withdraw(const AccountNumber: string;
  const Amount: Currency; const DateAndTime: TDateTime);
var
  BankAccount:IBankAccount;
  Withdraw:ITransaction;
begin
  if (Amount > 0) then
  begin
    BankAccount:= FindBankAccount(AccountNumber);
    if Assigned(BankAccount) then
    begin
      if (BankAccount.Balance > Amount) then
      begin
        Withdraw:=TTransaction.Create(Amount, DateAndTime, ttWithdraw);
        BankAccount.AddTransaction(Withdraw);
      end
      else
      begin
        raise EWithdrawException.Create(Format( sweExceededAmount, [AccountNumber]));
      end;
    end
    else
    begin
      raise EWithdrawException.Create(Format( sweInvalidAccountNumber, [AccountNumber]));
    end;
  end
  else
  begin
    raise EWithdrawException.Create(sweInvalidAmount);
  end;

end;

{ TAccount }

function TAccount.GetAccountNumber: string;
begin
  Result:= FAccountNumber;
end;

function TAccount.GetBalance: Currency;
begin
  Result:= 0;
end;

constructor TAccount.Create(const Customer: string; const MobileNumber:string; const AccountNumber: string);
begin
  inherited create;
  FCustomer:= TPerson.Create(Customer, MobileNumber);
  FAccountNumber:= AccountNumber;
end;

function TAccount.GetCustomer: IPerson;
begin
  Result:= FCustomer;
end;

destructor TAccount.Destroy;
begin
  FCustomer:= nil;
  tObject.free;

  inherited;
end;

{ TBankAccount }

function TBankAccount.GetAccountNumber: string;
var
  sAccountNumber:string;
begin
  sAccountNumber:= inherited GetAccountNumber;
  if sAccountNumber.IsEmpty then
  begin
    raise ECreateAccountException.Create(sceInvalidAccountNumber);
  end
  else
  begin
    Result:= sAccountNumber;
  end;
end;

procedure TBankAccount.AddTransaction(const Transaction: ITransaction);
begin
  FTransactions.Add(Transaction);
end;

function TBankAccount.GetBalance: Currency;
var
  Balance: Currency;
  Transaction: ITransaction;
begin
  Balance:= 0;
  for Transaction in Transactions do
  begin
    if (Transaction.TransactionType = ttDeposit) then
    begin
      Balance:= Balance + Transaction.Amount;
    end
    else
    begin
      Balance:= Balance - Transaction.Amount;
    end;
  end;
  Result:= Balance;
end;

constructor TBankAccount.Create(const Customer: string; const MobileNumber:string; const BankAccountType: TBankAccountType; const AccountNumber: string);
begin
  inherited Create(Customer, MobileNumber, AccountNumber);
  FBankAccountType:= BankAccountType;
  FTransactions:= TList<ITransaction>.Create;
end;

destructor TBankAccount.Destroy;
begin
  FreeAndNil(FTransactions);
  inherited;
end;

function TBankAccount.GetBankAccountType: TBankAccountType;
begin
  Result:= FBankAccountType;
end;

function TBankAccount.GetTransactions: TList<ITransaction>;
begin
  result:= FTransactions;
end;

{ TPerson }

constructor TPerson.Create(const CustomerName: string; const MobileNumber:string );
begin
  inherited create;
  FCustomerName:= CustomerName;
  FMobileNumber:= MobileNumber;
end;

function TPerson.GetMobileNumber: string;
begin
  Result:= FMobileNumber;
end;

function TPerson.GetName: string;
begin
  Result:= FCustomerName;
end;

{ TTransaction }

function TTransaction.GetAmount: Currency;
begin
  Result:= FAmount;
end;

constructor TTransaction.Create(Amount: Currency; Date: TDateTime;
  TransactionType: TTransactionType);
begin
  inherited create;
  FAmount:= Amount;
  FDate:= Date;
  FTransactionType:= TransactionType;
end;

function TTransaction.GetDate: TDateTime;
begin
  Result:= FDate;
end;

function TTransaction.GetTransactionType: TTransactionType;
begin
  Result:= FTransactionType;
end;

end.
