package sapo;

import common.Dispatch;
import common.Web;
import common.crypto.Random;
import common.db.MoreTypes.EmailAddress;
import common.db.MoreTypes.Privilege;
import common.spod.Survey;
import sapo.Spod;

@:build(sapo.MetaMacros.resolveMetas())
class TicketRoutes {
	@authorizeAll
	public function doDefault(?args:{ ?inbox:String, ?recipient:String, ?state:String })
	{
		if (args == null) args = { };
		var tickets : List<Spod.Ticket> = new List();
		var u = Context.loop.user;
		var tickets : List<Ticket> = new List();

		tickets = Ticket.manager.search(
		(args.inbox == "out"? $author == u : 1 == 1) &&
		(args.state == "open"? $closed_at == null:$closed_at != null)

		);

		if (args.inbox == "out")
		{

		}
		else if (args.inbox == "in")
		{
			//Todo: Spod Recipients
			//if(args.recipient == "all")
			//	tickets = Ticket.manager.search( (args.state == "open"? $closed_at == null:$closed_at != null));
			//else
			//	tickets = Ticket.manager.search( (args.state == "open"? $closed_at == null:$closed_at != null));
		}
		else
		{

		}

		/*tickets = Ticket.manager.search(
		switch args.inbox {
			case "in": 1 == 1; //$recipient == u;
			case "out": $author == u;
			default: 1==1;
		}

		$author == u


		);*/

		Sys.println(sapo.view.Tickets.render(tickets));
	}

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSearch(?args:{ ?ofUser:User, ?ticket:Ticket, ?survey:NewSurvey })
	{
		if (args == null) args = { };
		var tickets : List<Ticket> = new List();
		if (args.ticket != null)
			tickets.push(args.ticket);
		else if (args.survey != null)
			tickets = Ticket.manager.search($survey == args.survey);
		Sys.println(sapo.view.Tickets.render(tickets));
	}

	public function new() {}
}

@:build(sapo.MetaMacros.resolveMetas())
class SurveysRoutes
{
	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doDefault()
	{
		var surveys = Survey.manager.all();
		Sys.println(sapo.view.Surveys.render(surveys));
	}

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSearch(?args:{ ?survey:Survey })
	{
		if (args == null) args = { };
		var surveys : List<Survey> = new List();
		if (args.survey != null)
			surveys.add(args.survey);
		Sys.println(sapo.view.Surveys.render( surveys ));
	}

	public function new() {}
}

@:build(sapo.MetaMacros.resolveMetas())
class Routes
{
	@authorizeAll
	public function doDefault()
	{
		if (Context.loop.session == null) Web.redirect("/login");
		Web.redirect("/tickets");
	}

	@authorize(PPhoneOperator, PSuper, "PSupervisor")
	public function doTickets(d:Dispatch)
		d.dispatch(new TicketRoutes());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doRegistration()
		Sys.println(sapo.view.Registration.render());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doPayment()
		Sys.println(sapo.view.Payment.render());

	@authorizeAll
	public function doAbout()
		Sys.println(sapo.view.About.render());

	@authorizeAll
	public function doHelp()
		Sys.println(sapo.view.Help.render());

	@authorizeAll
	public function doLicenses()
	Sys.println(sapo.view.Licenses.render());

	@authorize("PSurveyor")
	public function doPayments()
		Sys.println(sapo.view.Payments.render());

	@authorize("PSurveyor", "PSupervisor", "PPhoneOperator", "PSuper")
	public function doSummary()
		Sys.println(sapo.view.Summary.render());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveysRoutes());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSurvey(s:sapo.NewSurvey)
		Sys.println(sapo.view.Survey.render(s));

	@authorizeAll
	public function doLogin()
		Sys.println(sapo.view.Login.render());

	@authorizeAll
	public function postLogin()
	{
		var p = Web.getParams();
		var email = p.get("email");
		var pass = p.get("password");

		var u = User.manager.search($email == new EmailAddress(email), null, false).first();
		if (u == null) {
			Web.redirect("default?error=" + StringTools.urlEncode("Usuário inválido!"));
			return;
		}
		//TODO: Validade password!
		if (!u.password.matches(pass)) {
			Web.redirect("default?error=" + StringTools.urlEncode("Senha inválida!"));
			return;
		}

		var s = new Session(u);
		s.insert();
		trace(s.expired());

		Web.setCookie(Session.COOKIE_KEY, s.id, s.expires_at);
		Web.redirect("/");
	}

	@authorizeAll
	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	public function new() { }
}

