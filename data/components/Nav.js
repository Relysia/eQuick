import styles from '../styles/Nav.module.sass';

function Nav(props) {
  return (
    <nav className={styles.nav}>
      <a href='#' className={styles['nav-link']} data-task='run' data-program='c:/Users/relys/Documents/Personal/webdevelopment/Learning/IntraLaunch' data-windowstate='max' data-showerrors='true'>
        <img src='folder.svg' alt='Open File Explorer' className={styles['nav-icon']} />
      </a>
      <a href='#' id='open-controls'>
        <img src='settings.svg' alt='Open Control Panel' className={styles['nav-icon']} />
      </a>
      <a href='#' id='lock-workstation'>
        <img src='lock.svg' alt='Lock Workstation' className={styles['nav-icon']} />
      </a>
    </nav>
  );
}

export default Nav;
