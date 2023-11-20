Var
  MyForm:TclGameForm;
  ImgBall, ImgHole:TclProImage;
  DeviceMotionSensor:TClMotionSensor;
  LblDisplay:TclLabel;
  GameTimer:TClTimer;
  BtnStartGame:TclButton;
  geribtn : TClProButton;
  SoundIndex:Integer;
  myDeviceManager:TclDeviceManager;
  HoleMin_X,HoleMax_X : Single; // Ball must be placed inside these coordinates
  HoleMin_Y,HoleMax_Y : Single;
  
  procedure geriprcdr
  begin
  TclProButton(MyForm.clFindComponent('BtnGoBack')).Click;
  end;

  function isBallinTheHole: Boolean;
  var
    centX,CentY : Single;
  begin
    Result := False;
    centX := ImgBall.Position.X + (ImgBall.Width/2);
    centY := ImgBall.Position.Y + (ImgBall.Height/2);
    if (centX <= HoleMax_X) and (centX >= HoleMin_X) and
       (centY <= HoleMax_Y) and (centY >= HoleMin_Y) then
      Result := True;
  end;

  Procedure ProcOnGameTimer;
  Const 
    BallSpeed = 5;
  begin
    //LblDisplay.Text := FormatDateTime('yymmdd0hhnnss', Now);
    //Clomosy.ProcessMessage;
    If Clomosy.PlatformIsMobile Then
    Begin
      Case DeviceMotionSensor.GetDirectionX of 
        1:ImgBall.Position.X := ImgBall.Position.X - BallSpeed;//Move left
        2:ImgBall.Position.X := ImgBall.Position.X + BallSpeed;//Move right
      End;
      Case DeviceMotionSensor.GetDirectionY of 
        1:ImgBall.Position.Y := ImgBall.Position.Y - BallSpeed;//Move up
        2:ImgBall.Position.Y := ImgBall.Position.Y + BallSpeed;//Move down
      End;
      if (ImgBall.Position.X + ImgBall.Width) > TForm(MyForm).ClientWidth then  // Form Right border control
        ImgBall.Position.X := TForm(MyForm).ClientWidth - ImgBall.Width;
    
      if (ImgBall.Position.X) < 0 then // Left border control
        ImgBall.Position.X := 0;
    
      if (ImgBall.Position.Y + ImgBall.Height) > TForm(MyForm).ClientHeight then  // Form Bottom border control
        ImgBall.Position.Y := TForm(MyForm).ClientHeight - ImgBall.Height;
    
      if (ImgBall.Position.Y < 0) then  // Top border control
        ImgBall.Position.Y := 0;
        
      if isBallinTheHole then
      begin
        GameTimer.Enabled := False;
        ImgBall.Position.X := HoleMin_X;
        ImgBall.Position.Y := HoleMin_Y;
        //ShowMessage(ImgBall.Position.X);
        If Clomosy.PlatformIsMobile Then DeviceMotionSensor.Active := False;//game stopped
        BtnStartGame.Text := 'START GAME';
        MyForm.PlayGameSound(SoundIndex);
        myDeviceManager.Vibrate(1000);
        ShowMessage('Tebrikler');
        //Buraya
      end;
        
    End;
  End
  Procedure BtnStartGameClick;
  begin
    GameTimer.Enabled := Not GameTimer.Enabled;
    If GameTimer.Enabled Then BtnStartGame.Text := 'STOP GAME' ELSE BtnStartGame.Text := 'START GAME';
    If GameTimer.Enabled Then
    Begin
      ImgBall.Align := alNone;
      ImgBall.Position.x := 0;
      ImgBall.Position.y := 0;
//      LblDisplay.Text := IntToStr(ImgBall.Position.x);
      If Clomosy.PlatformIsMobile Then DeviceMotionSensor.Active := True;
    End Else If Clomosy.PlatformIsMobile Then DeviceMotionSensor.Active := False;//game stopped
  End;
  
Begin
  //exit;
  MyForm := TclGameForm.Create(Self);
  myDeviceManager := TclDeviceManager.Create;
  MyForm.SetFormBGImage('https://clomosy.com/educa/bg3.png');
  
  MyForm.AddGameAssetFromUrl('https://www.clomosy.com/game/assets/win.wav');
  SoundIndex := MyForm.RegisterSound('win.wav');
  MyForm.SoundIsActive:=True;
  
  LblDisplay:= MyForm.AddNewLabel(MyForm,'LblDisplay','--');
  LblDisplay.Align := alTop;
  LblDisplay.Visible := False;
  //MyForm.LytTopBar.Visible := False;
  
  
  BtnStartGame:= MyForm.AddNewButton(MyForm,'BtnStartGame','START GAME');
  BtnStartGame.Align := alBottom;
  BtnStartGame.Height:=30;
  BtnStartGame.StyledSettings := ssFamily;
  BtnStartGame.TextSettings.FontColor := clAlphaColor.clHexToColor('#FFFFFF');
  BtnStartGame.Margins.Bottom := 50;
  //BtnStartGame.Visible := False;
  MyForm.AddNewEvent(BtnStartGame,tbeOnClick,'BtnStartGameClick');
  
  geribtn := MyForm.AddNewProButton(MyForm,'geribtn','');
  clComponent.SetupComponent(geribtn,'{"Align" : "None","Width":70,"Height":50,"ImgUrl":"https://img.icons8.com/flat-round/64/circled-left.png"}');
  MyForm.AddNewEvent(geribtn,tbeOnClick,'geriprcdr');
  geribtn.Position.X:=5;
  geribtn.Position.Y:=7;
  
  ImgHole := MyForm.AddNewProImage(MyForm,'ImgHole');
  ImgHole.clSetImage('https://clomosy.com/educa/station.png');
  ImgHole.Margins.Top:=120;
  ImgHole.Properties.AutoSize := True;
  ImgHole.Align := alCenter;

  ImgBall := MyForm.AddNewProImage(MyForm,'ImgBall');
  ImgBall.clSetImage('https://clomosy.com/educa/ufo.png');
  ImgBall.Width := 50;
  ImgBall.Height := 50;
  
  ImgBall.Align := alCenter;
  
  //ShowMessage(ImgBall.Position.Y);
  HoleMin_X := ImgBall.Position.X;
  HoleMax_X := HoleMin_X + ImgBall.Width; // Ball must be placed inside these coordinates
  
  HoleMin_Y := ImgBall.Position.Y+18;//LblDisplay.Visible true oldugunda orta nokta alınırken android de yanlış hesaplanıyor
  HoleMax_Y := HoleMin_Y + ImgBall.Height;
  ImgBall.Align := alNone;
  ImgBall.Position.Y := HoleMin_Y;
  //ShowMessage(ImgBall.Position.Y);
  //ShowMessage(HoleMin_Y);

  DeviceMotionSensor := MyForm.AddNewSensorsMotion(MyForm,'DeviceMotionSensor');

  GameTimer:= MyForm.AddNewTimer(MyForm,'GameTimer',1000);
  GameTimer.Interval := 30;//30 m.saniye aralıklarla 
  GameTimer.Enabled := False;
  MyForm.AddNewEvent(GameTimer,tbeOnTimer,'ProcOnGameTimer');
  //LblDisplay.Text := IntToStr(TForm(MyForm).ClientHeight) + '/' + IntToStr(TForm(MyForm).ClientWidth);
  
  //DeviceMotionSensor.Active := Clomosy.PlatformIsMobile;
  MyForm.Run;
  
End;