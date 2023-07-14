import logo from 'mastodon/../images/y-zu-logo.svg';

export const WordmarkLogo: React.FC = () => (
  <img src={logo} alt="" className='logo logo--wordmark' height="32px" />
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Mastodon' className='logo logo--icon' />
);
