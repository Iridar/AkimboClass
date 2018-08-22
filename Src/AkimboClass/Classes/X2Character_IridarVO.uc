class X2Character_IridarVO extends X2Character_DefaultCharacters;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSpeakerTemplate('IridarVO', "IridarVO", "img:///SoundSpeechIridar.IridarIcon"));

	return Templates;
}